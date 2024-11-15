{ pkgs, config, ... }:

{

  services.syncthing = {
    enable = true;
    # guiAddress = "omhe:8384";
    guiAddress = "100.114.14.104:8384";
    # user = config.users.users.fschn.name;
    user = "fschn";
    group = "users";
    dataDir = "/home/fschn";
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
        # proxyPass = "http://127.0.0.1:8384/";
        proxyPass = "http://100.114.14.104:8384";
      };
    };
  };

  # users.users.syncthing.extraGroups = [ "users" ];
  # users.users.fschn.extraGroups = [ "syncthing" ];
  # systemd.services.syncthing.serviceConfig.UMask = "0007";


}

