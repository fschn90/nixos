{ config, pkgs, ... }:
{

  services.prowlarr = {
    enable = true;
  };

  # allowing access to indexers behing cloudflare
  services.flaresolverr.enable = true;

  services.radarr = {
    enable = true;
  };

  # permissions for user
  users.users.radarr.extraGroups = [ "deluge" "jellyfin" ];

  services.nginx.virtualHosts = {
    "prowlarr.fschn.org" = {
      forceSSL = true;
      useACMEHost = "fschn.org";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.prowlarr.settings.server.port}";
      };
    };
    "radarr.fschn.org" = {
      forceSSL = true;
      useACMEHost = "fschn.org";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.radarr.settings.server.port}";
      };
    };
  };

  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = "prowlarr.fschn.org";
      answer = "${toString config.tailnet.omhe}";
      enabled = true;
    }
    {
      domain = "radarr.fschn.org";
      answer = "${toString config.tailnet.omhe}";
      enabled = true;
    }
  ];

  # binding privoxy to protonvpn network namespace
  services.privoxy.enable = true;
  systemd.services.privoxy.bindsTo = [ "netns@wg.service" ];
  systemd.services.privoxy.requires = [ "network-online.target" "wg.service" ];
  systemd.services.privoxy.serviceConfig.NetworkNamespacePath = [ "/var/run/netns/wg" ];

  # to access privoxy from the root namespace, a socket is necesarry
  systemd.sockets."proxy-to-privoxy" = {
    enable = true;
    description = "Socket for Proxy to Deluge Daemon";
    listenStreams = [ "8118" ];
    wantedBy = [ "sockets.target" ];
  };

  # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
  systemd.services."proxy-to-privoxy" = {
    enable = true;
    description = "Proxy to Privoxy in Network Namespace";
    requires = [ "privoxy.service" "proxy-to-privoxy.socket" ];
    after = [ "privoxy.service" "proxy-to-privoxy.socket" ];
    unitConfig = { JoinsNamespaceOf = "privoxy.service"; };
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:8118";
      PrivateNetwork = "yes";
    };
  };
}  
