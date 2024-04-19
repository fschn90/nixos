{ config, lib, pkgs, ... }:

{
  # Enable bluetooth

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  # showing battery charge of bluetooth devices, doesnt seem to work tho
  hardware.bluetooth.settings = {
	  General = {
		  Experimental = true;
	  };
  };

  # Media Player Remote Interface Specification: using headphone buttons to eg play next song
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

}

