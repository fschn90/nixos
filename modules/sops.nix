{ pkgs, config, ... }:

{

  environment.systemPackages = with pkgs; [
    sops
  ];

  sops = {

    defaultSopsFile = ../secrets/main.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/var/lib/sops-nix/key.txt";

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.generateKey = true;

    secrets."Users/fschn/Password".neededForUsers = true;

    secrets."networking/system-connections/wg-flocoding.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-flocoding.nmconnection";
    };
    secrets."networking/system-connections/wg-DE-329.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-CH-DE-1.nmconnection";
    };
  };
}  
