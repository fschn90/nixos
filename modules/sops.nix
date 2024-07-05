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

    secrets."ssh/config" = {
      mode = "0644";
      path = "/home/fschn/.ssh/config";
      owner = config.users.users.fschn.name;
    };
   
    secrets."ssh/authorized_keys" = {
      mode = "0600";
      path = "/home/fschn/.ssh/authorized_keys";
      owner = config.users.users.fschn.name;
    };

    secrets."ssh/keys/hetzner_flo" = {
      mode = "0600";
      path = "/home/fschn/.ssh/hetzner_flo";
      owner = config.users.users.fschn.name;
    };

    secrets."ssh/keys/hetzner_flo.pub" = {
      mode = "0644";
      path = "/home/fschn/.ssh/hetzner_flo.pub";
      owner = config.users.users.fschn.name;
    };
    
    secrets."ssh/keys/id_ed25519" = {
      mode = "0600";
      path = "/home/fschn/.ssh/id_ed25519";
      owner = config.users.users.fschn.name;
    };
   
    secrets."ssh/keys/id_ed25519.pub" = {
      mode = "0644";
      path = "/home/fschn/.ssh/id_ed25519.pub"; 
      owner = config.users.users.fschn.name;
    };
    
    secrets."Users/fschn/Password".neededForUsers = true;

    secrets."networking/system-connections/wg-flocoding.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-flocoding.nmconnection";
    };
    
    secrets."networking/system-connections/wg-CH-UK-1.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-CH-UK-1.nmconnection";
    };
    
    secrets."networking/system-connections/wg-CH-DE-1.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-CH-DE-1.nmconnection";
    };
    
    secrets."networking/system-connections/wg-CH-US-1.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-CH-US-1.nmconnection";
    };

    secrets."networking/system-connections/wg-CH-NL-1.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-CH-NL-1.nmconnection";
    };
    
    secrets."networking/system-connections/wg-CH-FR-1.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-CH-FR-1.nmconnection";
    };

    secrets."networking/system-connections/wg-CH-AT-1.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-CH-AT-1.nmconnection";
    };
    
    secrets."networking/system-connections/wg-NL-323-P2P.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-NL-323-P2P.nmconnection";
    };

    secrets."networking/system-connections/wg-FR-13-TOR.nmconnection" = {
      mode = "0600";
      path = "/etc/NetworkManager/system-connections/wg-FR-13-TOR.nmconnection";
    };
  };
}  
