{ config, ... }:

{
  users.users.fschn = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # wheel to enable ‘sudo’ for the user.
    hashedPasswordFile = config.sops.secrets."Users/fschn/Password".path;
  };

  users.mutableUsers = true;
}
