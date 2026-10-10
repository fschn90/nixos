# modules/agent-herd.nix
#
# Agent host: Herdr (runtime) + Collie (phone PWA) + Pi (harness) behind nginx.
#
#   phone ──HTTPS──▶ nginx ──▶ 127.0.0.1:8787 Collie bridge ──socket──▶ Herdr server ──▶ pi panes
#
# Everything runs as ONE unprivileged user, as systemd *user* services (with
# linger), so Herdr's socket lives in that user's XDG_RUNTIME_DIR and the
# interactive `herdr` client finds the same server when you ssh in.
#
# Expects these flake inputs (passed through `specialArgs = { inherit inputs; }`):
#   herdr      = github:herdrdev/herdr/v0.9.3
#   collie     = github:AltanS/collie
#   llm-agents = github:numtide/llm-agents.nix
{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib)
    mkOption mkEnableOption mkIf mkMerge mkDefault types
    optional optionals optionalAttrs optionalString concatStringsSep;

  cfg = config.services.agentHerd;
  ngx = cfg.nginx;
  system = pkgs.stdenv.hostPlatform.system;

  # What nginx puts into X-Device-Id (so Collie can split read-only vs. write).
  # Only meaningful if nginx itself authenticates something per device.
  deviceIdVar =
    if ngx.clientCA != null then "$agent_herd_device" # mTLS: certificate CN
    else if ngx.basicAuthFile != null then "$remote_user" # basic auth: username
    else null;
in
{
  options.services.agentHerd = {
    enable = mkEnableOption "Herdr + Collie + Pi agent host";

    user = mkOption {
      type = types.str;
      default = "agent";
      description = ''
        User that runs Herdr, Collie and every agent. Collie is remote shell
        access by design, so use a dedicated user instead of your main account.
      '';
    };

    createUser = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Create `user` as a normal user. It has no password and no SSH key;
        add `users.users.<name>.openssh.authorizedKeys.keys` yourself.
      '';
    };

    herdr = {
      package = mkOption {
        type = types.package;
        default = inputs.herdr.packages.${system}.default;
        defaultText = "inputs.herdr.packages.\${system}.default";
        description = "Herdr package (the upstream flake builds from source).";
      };
      extraPath = mkOption {
        type = with types; listOf (oneOf [ package str ]);
        default = [ ];
        description = "Extra entries for the PATH of the Herdr server (and so of every pane).";
      };
      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/run/secrets/agents/env";
        description = ''
          EnvironmentFile for the Herdr server, e.g. a sops-nix secret holding
          ANTHROPIC_API_KEY=... Panes inherit it, so Pi sees the keys.
          Must be readable by `user`.
        '';
      };
    };

    collie = {
      package = mkOption {
        type = types.package;
        default = inputs.collie.packages.${system}.collie;
        defaultText = "inputs.collie.packages.\${system}.collie";
        description = "Collie package.";
      };
      port = mkOption {
        type = types.port;
        default = 8787;
        description = "Loopback port of the Collie bridge.";
      };
      devices = mkOption {
        type = with types; listOf str;
        default = [ ];
        example = [ "phone" ];
        description = ''
          Device ids allowed to drive agents (COLLIE_DEVICE_ALLOWLIST); all
          others are read-only. Needs `nginx.clientCA` (id = certificate CN) or
          `nginx.basicAuthFile` (id = username). Leave empty to rely on
          Collie's own device pairing (`collie pair`).
        '';
      };
      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Extra secret env for Collie (e.g. Web Push VAPID keys, see docs/voice-and-push.md).";
      };
      settings = mkOption {
        type = with types; attrsOf str;
        default = { };
        example = { COLLIE_POLL_IDLE_MS = "5000"; };
        description = "Extra COLLIE_* environment variables.";
      };
    };

    pi.package = mkOption {
      type = types.package;
      default = inputs.llm-agents.packages.${system}.pi;
      defaultText = "inputs.llm-agents.packages.\${system}.pi";
      description = "Pi coding agent. Configure it (models, settings) via home-manager or ~/.pi/agent.";
    };

    nginx = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Publish Collie through an nginx virtual host.";
      };
      domain = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "agents.example.org";
        description = "Public host name. Also feeds COLLIE_PUBLIC_HOSTS / COLLIE_ALLOWED_ORIGINS.";
      };
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open TCP 80/443.";
      };
      allowedCIDRs = mkOption {
        type = with types; listOf str;
        default = [ ];
        example = [ "192.168.1.0/24" "100.64.0.0/10" "fd7a:115c:a1e0::/48" ];
        description = "Only these networks may reach the vhost (LAN, tailnet, WireGuard, ...).";
      };
      basicAuthFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          htpasswd file, readable by the nginx user. Beware: browsers fetch the
          PWA manifest without credentials, which can break "Add to Home Screen"
          behind basic auth. Prefer allowedCIDRs or clientCA.
        '';
      };
      clientCA = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "CA certificate; if set, nginx requires a client certificate (mTLS) and uses its CN as the device id.";
      };
      virtualHost = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        example = { enableACME = false; useACMEHost = "example.org"; };
        description = "Extra services.nginx.virtualHosts.<domain> settings (override ACME, listen addresses, ...).";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !ngx.enable || ngx.domain != null;
          message = "services.agentHerd.nginx.domain must be set.";
        }
        {
          # Collie == shell on this machine. Never publish it with no gate.
          assertion = !ngx.enable
            || ngx.allowedCIDRs != [ ] || ngx.basicAuthFile != null || ngx.clientCA != null;
          message = ''
            services.agentHerd.nginx: set at least one of allowedCIDRs,
            basicAuthFile or clientCA. Collie gives shell access to this machine.
          '';
        }
        {
          assertion = cfg.collie.devices == [ ] || deviceIdVar != null;
          message = "services.agentHerd.collie.devices needs nginx.clientCA or nginx.basicAuthFile to derive a device id.";
        }
      ];

      environment.systemPackages = [ cfg.herdr.package cfg.collie.package cfg.pi.package ];

      users.users.${cfg.user} = mkMerge [
        (mkIf cfg.createUser {
          isNormalUser = true;
          description = "AI agent runtime";
        })
        # keep the user manager (and therefore Herdr) alive without a login
        { linger = true; }
      ];

      # ── Herdr: headless server, owns the terminals ────────────────────────
      systemd.user.services.herdr = {
        description = "Herdr agent runtime";
        wantedBy = [ "default.target" ];
        unitConfig.ConditionUser = cfg.user;
        # A rebuild must never kill running agents; restart by hand when you want to.
        restartIfChanged = false;
        # Panes inherit this PATH unless the shell resets it.
        path = [ "/run/current-system/sw" "/etc/profiles/per-user/${cfg.user}" cfg.pi.package ]
          ++ cfg.herdr.extraPath;
        serviceConfig = {
          ExecStart = "${cfg.herdr.package}/bin/herdr server";
          ExecStop = "${cfg.herdr.package}/bin/herdr server stop";
          Restart = "on-failure";
          RestartSec = 5;
        } // optionalAttrs (cfg.herdr.environmentFile != null) {
          EnvironmentFile = cfg.herdr.environmentFile;
        };
      };

      # ── Collie: loopback bridge, nginx is the only front door ─────────────
      # NOTE: `_exec-bridge` is the internal verb Collie's own generated unit
      # uses (see its docs/deployment.md). Compare with `systemctl --user cat
      # collie` after a manual `COLLIE_SKIP_SERVE=1 collie start` if it breaks.
      systemd.user.services.collie = {
        description = "Collie bridge (Herdr mobile client)";
        wantedBy = [ "default.target" ];
        after = [ "herdr.service" ];
        wants = [ "herdr.service" ];
        unitConfig.ConditionUser = cfg.user;
        environment = {
          COLLIE_MUX = "herdr";
          COLLIE_HOST = "127.0.0.1";
          COLLIE_PORT = toString cfg.collie.port;
          COLLIE_SKIP_SERVE = "1"; # never touch `tailscale serve`
          COLLIE_PLUGIN_ROOT = "${cfg.collie.package}/lib/collie";
        }
        // optionalAttrs ngx.enable {
          COLLIE_PUBLIC_HOSTS = ngx.domain;
          COLLIE_ALLOWED_ORIGINS = "https://${ngx.domain}";
          COLLIE_PUBLIC_URL = "https://${ngx.domain}";
        }
        // optionalAttrs (cfg.collie.devices != [ ]) {
          COLLIE_DEVICE_HEADER = "X-Device-Id";
          COLLIE_DEVICE_ALLOWLIST = concatStringsSep "," cfg.collie.devices;
        }
        // cfg.collie.settings;
        serviceConfig = {
          ExecStart = "${cfg.collie.package}/bin/collie _exec-bridge";
          Restart = "on-failure";
          RestartSec = 5;
          # %h = the user's home; leading "-" = optional file (collie writes it itself)
          Environment = [ "HERDR_PLUGIN_CONFIG_DIR=%h/.config/collie" ];
          EnvironmentFile = [ "-%h/.config/collie/.env" ]
            ++ optional (cfg.collie.environmentFile != null) cfg.collie.environmentFile;
        };
      };
    }

    # ── nginx ────────────────────────────────────────────────────────────────
    (mkIf ngx.enable {
      networking.firewall.allowedTCPPorts = mkIf ngx.openFirewall [ 80 443 ];

      services.nginx = {
        enable = true;
        recommendedProxySettings = true; # Host $host etc.: Collie validates Host
        recommendedTlsSettings = true;

        # mTLS: device id = CN of the verified client certificate
        commonHttpConfig = optionalString (ngx.clientCA != null) ''
          map $ssl_client_s_dn $agent_herd_device {
            default "";
            "~CN=(?<cn>[^,/]+)" $cn;
          }
        '';

        virtualHosts.${ngx.domain} = mkMerge [
          {
            forceSSL = mkDefault true;
            useACMEHost = "fschn.org";
            basicAuthFile = ngx.basicAuthFile;

            extraConfig = concatStringsSep "\n" (
              map (c: "allow ${c};") ngx.allowedCIDRs
              ++ optional (ngx.allowedCIDRs != [ ]) "deny all;"
              ++ optionals (ngx.clientCA != null) [
                "ssl_client_certificate ${ngx.clientCA};"
                "ssl_verify_client on;"
              ]
            );

            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.collie.port}";
              proxyWebsockets = true;
              # origin Cache-Control (sw.js, index.html) must pass through untouched
              extraConfig = ''
                proxy_buffering off;
              '' + optionalString (cfg.collie.devices != [ ]) ''
                # overrides whatever the client sent, so it cannot be spoofed
                proxy_set_header X-Device-Id ${deviceIdVar};
              '';
            };
          }
          ngx.virtualHost
        ];
      };
    })
  ]);
}
