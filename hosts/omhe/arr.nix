{ config, pkgs, ... }:
{

  services.prowlarr = {
    enable = true;
  };

  services.nginx.virtualHosts."prowlarr.fschn.org" = {
    forceSSL = true;
    useACMEHost = "fschn.org";
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.prowlarr.settings.server.port}";
    };
  };

  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = "prowlarr.fschn.org";
      answer = "${toString config.tailnet.omhe}";
    }
  ];

}  
