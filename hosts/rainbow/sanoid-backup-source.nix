{ config, ... }:

{

  sops = {

    # secrets."ssh/keys/backup" = {
    #   mode = "0604";
    #   path = "/var/lib/syncoid/backup";
    #   owner = config.users.users.backup.name;
    # };
    
    secrets."ssh/keys/backup" = {
      # mode = "0600";
      # path = "/home/fschn/.ssh/backup";
      # owner = config.users.users.fschn.name;
    };
   
    secrets."ssh/keys/backup.pub" = {
      # mode = "0644";
      # path = "/home/fschn/.ssh/backup.pub"; 
      # owner = config.users.users.fschn.name;
    };   
  
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
      # authorizedKeys.keyFiles = [ config.sops.secrets."ssh/keys/backup.pub".path ];
    };
  };

}
