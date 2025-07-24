{ pkgs, config, ... }:

{
  systemd.tmpfiles.rules = [
    "d /home/fschn/.config/syncthing - fschn users"
  ];

  services.syncthing = {
    enable = true;
    guiAddress = "${toString config.tailnet.rainbow}:8384";
    user = "fschn";
    group = "users";
    dataDir = "/home/fschn";
    configDir = "/home/fschn/.config/syncthing";
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
          id = "CZPM2MR-QCNNKMX-ESB2KUO-ASI76LX-2H7PLRW-4OT6XIU-YNX7TEU-T22RCQO";
          address = "tcp://${toString config.tailnet.omhe}:220000";
        };
      };
      folders = {
        "PAPERLESS-CONSUME" = {
          path = "/home/fschn/Documents/PAPERLESS-CONSUME";
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
        proxyPass = "http://${toString config.tailnet.rainbow}:8384";
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
}
