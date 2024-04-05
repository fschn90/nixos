{ config, lib, pkgs, ... }:


{
 
  users.users.fschn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    # hashedPasswordFile = config.sops.secrets."Users/fschn/Password".path;
  };

  users.mutableUsers = true;

}
