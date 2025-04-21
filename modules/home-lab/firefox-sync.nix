{ lib, pkgs, config, ... }:

{
  services.mysql.package = pkgs.mariadb;

  services.firefox-syncserver = {
    enable = true;
    secrets = config.sops.secrets."firefox-syncserver/SYNC_MASTER_SECRET".path;
    settings.host = "0.0.0.0";
    singleNode = {
      enable = true;
      capacity = 3;
      # hostname = "firefox-sync.fschn.org";
      hostname = "0.0.0.0";
      url = "https://firefox-sync.fschn.org";
      # hostname = "localhost";
      # url = "http://localhost:5000";
      enableNginx = true;
      # enableTLS = true;
    };
  };


  sops.secrets."firefox-syncserver/SYNC_MASTER_SECRET" = {
    mode = "0777";
  };

  services.nginx = {
    virtualHosts."firefox-sync.fschn.org" = {
      useACMEHost = "fschn.org";
      # avoiding error `The option has conflicting definition values` with lib.mkForce
      forceSSL = lib.mkForce true;
    };
  };
}
