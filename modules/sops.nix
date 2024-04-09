{ config, lib, pkgs, ... }:

{

  sops = {

  defaultSopsFile = ../secrets/example.yaml;
  defaultSopsFormat = "yaml";
  
  age.keyFile = "/home/fschn/.config/sops/age/keys.txt";

  secrets."ssh/config" = {
    mode = "0644";
    path = "/home/fschn/.ssh/config";
    owner = "fschn";
  };
 
  secrets."ssh/keys/hetzner_flo" = {
    mode = "0600";
    path = "/home/fschn/.ssh/hetzner_flo";
    owner = "fschn";
  };
 
  secrets."ssh/keys/hetzner_flo.pub" = {
    mode = "0644";
    path = "/home/fschn/.ssh/hetzner_flo.pub";
    owner = "fschn";
  };
  
  secrets."ssh/keys/id_ed25519" = {
    mode = "0600";
    path = "/home/fschn/.ssh/id_ed25519";
    owner = "fschn";
  };
 
  secrets."ssh/keys/id_ed25519.pub" = {
    mode = "0644";
    path = "/home/fschn/.ssh/id_ed25519.pub"; 
    owner = "fschn";
  };
  
  secrets."myservice/my_subdir/my_secret" = {};
  secrets."Users/fschn/Password".neededForUsers = true;
  };
}  
