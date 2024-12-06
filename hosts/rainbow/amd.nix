{ config, lib, pkgs, ... }:

{

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  # hardware.opengl.extraPackages = with pkgs; [
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

} 
