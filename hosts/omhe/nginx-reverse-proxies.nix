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
      "ai.fschn.org" = {
        forceSSL = true;
        useACMEHost = "fschn.org";
        locations."/" = {
          proxyPass = "http://100.114.14.104:8080";
        };
      };
    };
  };

}
