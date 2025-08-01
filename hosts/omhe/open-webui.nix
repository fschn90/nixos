  services.open-webui = {
    enable = true;
    package = pkgs.unstable.open-webui;
    host = config.tailnet.omhe;
  };
  services.nginx = {
    virtualHosts = {
      "ai.fschn.org" = {
        forceSSL = true;
        useACMEHost = "fschn.org";
        locations."/" = {
          proxyPass = "http://${toString config.tailnet.omhe}:8080";
          proxyWebsockets = true;
        };
      };
    };
  };

}
