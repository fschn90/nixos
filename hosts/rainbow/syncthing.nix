{ pkgs, config, ... }:

{

  services.syncthing = {
    enable = true;
    guiAddress = "100.114.14.104:8384";
    user = "fschn";
    group = "users";
    dataDir = "/home/fschn";
    openDefaultPorts = true;
    settings.gui = {
      user = "fschn";
    };
    overrideDevices = true;
    overrideFolders = true;
    settings.options = {
      globalAnnounceEnabled = false;
      localAnnounceEnabled = true;
      urAccepted = -1;
    };
    settings = {
      devices = {
        "omhe" = {
          id = "5JOBVZM-DSBMHPK-MY5LAOS-OLBTSLW-EUHASPW-RJA4KIC-QHSBYPV-VEBSNQW";
          address = "tcp://100.106.245.44:220000";
        };
      };
      folders = {
        "PAPERLESS-CONSUME" = {
          path = "/home/fschn/PAPERLESS-CONSUME";
          devices = [ "omhe" ];
          syncOwnership = true;
          sendOwnership = true;
        };
        "Photos" = {
          path = "/home/fschn/Pictures";
          devices = [ "omhe" ];
          syncOwnership = true;
          sendOwnership = true;
        };
      };
    };
  };

  services.nginx = {
    virtualHosts."syncthing-${builtins.toString config.networking.hostName}.fschn.org" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://100.114.14.104:8384";
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

}
