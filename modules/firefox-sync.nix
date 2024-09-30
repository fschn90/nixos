{ pkgs, config, ... }:

{
  services.mysql.package = pkgs.mariadb;

  services.firefox-syncserver = {
    enable = true;
    # secrets = builtins.toFile "sync-secrets" ''
    #   SYNC_MASTER_SECRET=this-secret-is-actually-leaked-to-/nix/store
    # '';
    secrets = config.sops.secrets."firefox-syncserver/SYNC_MASTER_SECRET".path;
    singleNode = {
      enable = true;
      hostname = "localhost";
      url = "http://localhost:5000";
    };
  };


  sops.secrets."firefox-syncserver/SYNC_MASTER_SECRET" = {
    # mode = "0600";
    # path = "/etc/NetworkManager/system-connections/wg-flocoding.nmconnection";
  };

  services.nginx = {
    virtualHosts."firefox-sync.fschn.org" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.firefox-syncserver.settings.port}";
      };
    };
  };
}
