{ pkgs, config, ... }:

{

  services.syncthing = {
    enable = true;
    guiAddress = "${toString config.tailnet.rainbow}:8384";
    # needs to run as system user to avoid permission issues
    user = "fschn";
    group = "users";
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
          id = "X7H2IMZ-JHIPBB2-WXBVUCM-LGLUGDW-ZZ2NYUP-6VS3JGG-ZHSL5TC-XRRG7QT";
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
