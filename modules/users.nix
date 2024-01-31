{ config, lib, pkgs, ... }:

{

  users.users.fschn = {
    isNormalUser = true;
    initialPassword = "pw321"; # change password immediatly
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    # packages = with pkgs; [
    # ];
  };

  users.mutableUsers = true;

}
