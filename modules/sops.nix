{ config, lib, pkgs, ... }:

{

  sops = {

  defaultSopsFile = ../secrets/example.yaml;
  defaultSopsFormat = "yaml";
  
  age.keyFile = "/home/fschn/.config/sops/age/keys.txt";

  secrets.example-key = {};
  secrets."myservice/my_subdir/my_secret" = {};
  secrets."Users/fschn/Password".neededForUsers = true;
  };
}  
