{ config, ... }:

{

  services.scrutiny.enable = true;
  services.scrutiny.collector.enable = true;
  services.scrutiny.settings.web.listen.port = 8081;

  services.nginx = {
    virtualHosts."scrutiny-${builtins.toString config.networking.hostName}.fschn.org" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${builtins.toString config.services.scrutiny.settings.web.listen.port}";
      };
    };
  };
}
