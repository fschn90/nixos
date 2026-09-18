{

  services.postgresql = {
    enable = true;
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [ "nextcloud" "immich" "paperless" "grafana" ];
  };

}
