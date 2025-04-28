{ pkgs, config, ... }:

{

  services.syncthing = {
    enable = true;
    # guiAddress = "omhe:8384";
    guiAddress = "100.106.245.44:8384";
    openDefaultPorts = true;
    # user = config.users.users.fschn.name;
    user = "fschn";
    group = "users";
    dataDir = "/tank/Paperless";
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
        "rainbow" = {
          id = "MSBKHEW-54C7Z5L-O65KLIJ-PCQZW72-C4ODMY3-SE4IXQQ-KWI2LPU-5YTVNQW";
          address = "tcp://100.114.14.104:220000";
        };
        "berry" = {
          id = "DAG4S4R-CCZDIMK-R7CPHD4-XBCO45P-UI2T6JS-TG2CY2K-C4IFHXF-DJE4QAE";
          address = "tcp://100.65.150.91:220000";
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
        # "NixOS" = {
        #  path = "/etc/nixos/";
        #  devices = [ "rainbow" "berry" ];
        #  syncOwnership = true;
        #  sendOwnership = true;
        # };
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
        proxyPass = "http://100.106.245.44:8384";
      };
    };
  };

  # users.users.syncthing.extraGroups = [ "users" ];
  # users.users.fschn.extraGroups = [ "syncthing" ];
  # systemd.services.syncthing.serviceConfig.UMask = "0007";

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

}

