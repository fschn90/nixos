{ pkgs, config, ... }:

{

  services.syncthing = {
    enable = true;
    guiAddress = "${toString config.tailnet.omhe}:8384";
    openDefaultPorts = true;
    # needs to run as system user to avoid permission issues
    user = "fschn";
    group = "users";
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
        "rainbow" = {
          id = "XGAUTJ5-E7LH5CR-C6N3ONB-YWB6YHV-6AO7GXJ-LK5VOUX-3ATR2VN-LZV3KQE";
          address = "tcp://${toString config.tailnet.rainbow}:220000";
        };
      };
      folders = {
        "PAPERLESS-CONSUME" = {
          path = "/tank/Paperless/from-rainbow";
          devices = [ "rainbow" ];
          syncOwnership = true;
          sendOwnership = true;
        };
        "Photos" = {
          path = "/tank/Photos";
          devices = [ "rainbow" ];
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
        proxyPass = "http://${toString config.tailnet.omhe}:8384";
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
}

