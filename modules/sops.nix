{ config, lib, pkgs, ... }:

{

  sops = {
    gnupg.home = "/home/fschn/.gnupg"; # must have no password!
    # It's also possible to use a ssh key, but only when it has no password:
    #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    defaultSopsFile = /etc/nixos/secrets/secret.yaml;
    secrets.example-key = {};  
    secrets."myservice/my_subdir/my_secret" = {};
    gnupg.sshKeyPaths = [];
  };

} 
