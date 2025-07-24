{ pkgs, config, ... }:

{

  services.syncthing = {
    enable = true;
    guiAddress = "${toString config.tailnet.omhe}:8384";
    openDefaultPorts = true;
    user = "fschn";
    group = "users";
    # dataDir = "/tank/Paperless";
    configDir = "/home/fschn/.config/syncthing";
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
          id = "MSBKHEW-54C7Z5L-O65KLIJ-PCQZW72-C4ODMY3-SE4IXQQ-KWI2LPU-5YTVNQW";
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

