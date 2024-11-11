{ pkgs, config, ... }:

{

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings.gui = {
      user = "myuser";
      password = "mypassword";
    };
  };


  services.nginx = {
    virtualHosts."syncthing-${builtins.toString config.networking.hostName}.fschn.org" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations."/" = {
        # proxyPass = "http://localhost:${builtins.toString config.services.scrutiny.settings.web.listen.port}";
        # proxyPass = "http://localhost:8384;
        proxyPass = "http://127.0.0.1:8384/";
      };
    };
  };

}

