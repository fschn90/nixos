{ config, lib, pkgs, ... }:

{

  sops = {

  defaultSopsFile = ../secrets/example.yaml;
  defaultSopsFormat = "yaml";
  
  age.keyFile = "/home/fschn/.config/sops/age/keys.txt";

  secrets.example-key = {
    path = "/home/fschn/.ssh/config";
    owner = "fschn";
    mode = "0600"
  };
  secrets."myservice/my_subdir/my_secret" = {};
  secrets."Users/fschn/Password".neededForUsers = true;
  };
}  
