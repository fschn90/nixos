{ pkgs, config, ... }:

let
  backupDirDaily = "/tank/Paperless/backup-daily/";
  backupDirMonthly = "/tank/Paperless/backup-monthly/";

  restore-paperless = pkgs.writeShellApplication {
    name = "restore-paperless";
    text = ''
      sudo -u paperless /run/current-system/sw/bin/paperless-manage document_importer "${backupDirDaily}"
    '';
  };
in

{

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."paperless/admin-password".path;
    consumptionDirIsPublic = true;
    # address = "paperless.fschn.org";
    dataDir = "/tank/Paperless";
    consumptionDir = "${config.services.paperless.dataDir}/from-rainbow";
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
        continue_on_soft_render_error = true; # avoid error: Ghostscript rasterizing failed. 
        invalidate_digital_signatures = true; # avoid error: DigitalSignatureError: Input PDF has a digital signature. OCR would alter the document, invalidating the signature.

      };
      PAPERLESS_TIME_ZONE = "Europe/Vienna";
      PAPERLESS_TASK_WORKERS = 2;
      PAPERLESS_THREADS_PER_WORKER = 1;
      PAPERLESS_WEBSERVER_WORKERS = 2;
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_CONSUMER_DELETE_DUPLICATES = true;
      # PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
      PAPERLESS_URL = "https://paperless.fschn.org"; # neccessary to avoid error: [WARNING] [django.security.csrf] Forbidden (Origin checking failed - https://paperless.fschn.org does not match any trusted origins.): /accounts/login/
      PAPERLESS_DBHOST = "/run/postgresql";
      PAPERLESS_DBUSER = "paperless";
      PAPERLESS_DBNAME = "paperless";
    };
  };

  users.users.paperless.extraGroups = [ "users" ];

  services.nginx.virtualHosts."paperless.fschn.org" = {
    forceSSL = true;
    useACMEHost = "fschn.org";
    locations."/" = {
      proxyPass = "http://localhost:28981";
    };
  };

  sops.secrets."paperless/admin-password" = {
    owner = "paperless";
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "paperless" ];
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
  };

  environment.systemPackages = [ restore-paperless ];


  systemd.tmpfiles.rules = [
    "d ${backupDirDaily} 0750 paperless paperless  -"
    "d ${backupDirMonthly} 0750 paperless paperless  -"
  ];


  systemd = {
    timers."paperless-backup-daily" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "paperless-backup-daily.service";
      };
    };
    timers."paperless-backup-monthly" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "monthly";
        Persistent = true;
        Unit = "paperless-backup-monthly.service";
      };
    };

    services."paperless-backup-daily" = {
      script = ''
        /run/current-system/sw/bin/paperless-manage document_exporter "${backupDirDaily}" -p -d
        /run/current-system/sw/bin/paperless-manage document_create_classifier
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
    services."paperless-backup-monthly" = {
      script = ''
        /run/current-system/sw/bin/paperless-manage document_exporter "${backupDirMonthly}" -z
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };

}
