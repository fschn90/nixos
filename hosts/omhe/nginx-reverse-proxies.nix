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
    };
  };

}
