{ pkgs, config, ... }:

{

  services.guacamole-server = {
    enable = true;
    host = "127.0.0.1";
    # userMappingXml = ./guacamole/user-mapping.xml;
    userMappingXml = config.sops.secrets."guacamole/user-mapping.xml".path;
    package = pkgs.unstable.guacamole-server; # Optional, use only when you want to use the unstable channel
  };

  services.guacamole-client = {
    enable = true;
    enableWebserver = true;
    settings = {
      guacd-port = 4822;
      guacd-hostname = "127.0.0.1";
    };
    package = pkgs.unstable.guacamole-client; # Optional, use only when you want to use the unstable channel
  };

  sops.secrets."guacamole/user-mapping.xml" = { };

  #   services.nginx = {
  #   virtualHosts."guacaomle.fschn.org" = {
  #     useACMEHost = "fschn.org";
  #     forceSSL = true;
  #     locations."/" = {
  #       proxyPass = "http://localHost:${toString config.services.deluge.web.port}";
  #     };
  #   };
  # };


        services.adguardhome.settings.filtering.rewrites = [
          {
            domain = "remote.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
        ];

      }
