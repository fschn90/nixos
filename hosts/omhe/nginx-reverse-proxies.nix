{ config, ... }:
{
  services.nginx = {
    virtualHosts = {
      "fritzbox.fschn.org" = {
        useACMEHost = "fschn.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.178.1";
        };
      };
      "wled.fschn.org" = {
        useACMEHost = "fschn.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.178.147";
        };
      };
    };
  };


  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = "firtzbox.fschn.org";
      answer = "${toString config.tailnet.omhe}";
    }
    {
      domain = "wled.fschn.org";
      answer = "${toString config.tailnet.omhe}";
    }
  ];
}
