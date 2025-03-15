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
      user = "fschn";
      # password = "mypassword";
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
        "berry" = {
          id = "DAG4S4R-CCZDIMK-R7CPHD4-XBCO45P-UI2T6JS-TG2CY2K-C4IFHXF-DJE4QAE";
          address = "tcp://100.65.150.91:220000";
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
        "NixOS" = {
          path = "/etc/nixos/";
          devices = [ "omhe" "berry" ];
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

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

}

