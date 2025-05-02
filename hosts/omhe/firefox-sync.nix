{ lib, pkgs, config, ... }:

{
  services.mysql.package = pkgs.mariadb;

  services.firefox-syncserver = {
    enable = true;
    secrets = config.sops.secrets."firefox-syncserver/SYNC_MASTER_SECRET".path;
    settings.host = "0.0.0.0";
    singleNode = {
      enable = true;
      capacity = 4;
      hostname = "0.0.0.0";
      # enableNginx = true;
      url = "https://ffsync.fschn.org";
    };
  };


  sops.secrets."firefox-syncserver/SYNC_MASTER_SECRET" = { };

  services.nginx = {
    virtualHosts."ffsync.fschn.org" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5000";
      };
    };
  };
}
