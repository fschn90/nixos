{ lib, pkgs, config, ... }:

{
  services.mysql.package = pkgs.mariadb;

  services.firefox-syncserver = {
    enable = true;
    secrets = config.sops.secrets."firefox-syncserver/SYNC_MASTER_SECRET".path;
    singleNode = {
      enable = true;
      hostname = "firefox-sync.fschn.org";
      # hostname = "localhost";
      # url = "http://localhost:5000";
      enableNginx = true;
    };
  };


  sops.secrets."firefox-syncserver/SYNC_MASTER_SECRET" = { };

  services.nginx = {
    virtualHosts."firefox-sync.fschn.org" = {
      useACMEHost = "fschn.org";
      # avoiding error `The option has conflicting definition values` with lib.mkForce
      forceSSL = lib.mkForce true;
    };
  };
}
