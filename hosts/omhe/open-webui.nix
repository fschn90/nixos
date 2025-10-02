{ pkgs, config, ... }:

{

  services.open-webui = {
    enable = true;
    # package = pkgs.unstable.open-webui;
    host = config.tailnet.omhe;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://${toString config.tailnet.rainbow}:11434";
      DATABASE_URL = "postgresql:///open-webui?host=/run/postgresql";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "open-webui" ];
    ensureUsers = [
      {
        name = "open-webui";
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx = {
    virtualHosts = {
      "ai.fschn.org" = {
        forceSSL = true;
        useACMEHost = "fschn.org";
        locations."/" = {
          proxyPass = "http://${toString config.tailnet.omhe}:${toString config.services.open-webui.port}";
          proxyWebsockets = true;
        };
      };
    };
  };

}
