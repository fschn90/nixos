{

  sops = {

    secrets."ssh/keys/backup.pub" = {};

  };


  users.users.backup = {
    isNormalUser = true;
    createHome = false;
    home = "/var/empty";
    extraGroups = [ ];
    openssh = {
      authorizedKeys.keys = [
        config.sops.secrets."ssh/keys/backup.pub".path
      ];
    };
  };

}
