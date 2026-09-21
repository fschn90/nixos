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
    package = pkgs.unstable.paperless-ngx;
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
      # PAPERLESS_TASK_WORKERS = 2;
      # PAPERLESS_THREADS_PER_WORKER = 1;
      # PAPERLESS_WEBSERVER_WORKERS = 2;
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_CONSUMER_DELETE_DUPLICATES = true;
      PAPERLESS_EMAIL_TASK_CRON = "0 * * * *";
      # PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
      PAPERLESS_URL = "https://paperless.fschn.org"; # neccessary to avoid error: [WARNING] [django.security.csrf] Forbidden (Origin checking failed - https://paperless.fschn.org does not match any trusted origins.): /accounts/login/
      PAPERLESS_DBENGINE = "postgresql";
      PAPERLESS_DBHOST = "/run/postgresql";
      PAPERLESS_DBUSER = "paperless";
      PAPERLESS_DBNAME = "paperless";
      # PAPERLESS_AI_ENABLED = true;
    };
    environmentFile = config.sops.secrets."paperless/env".path;
  };

  users.users.paperless.extraGroups = [ "users" ];

  users.users.fschn.extraGroups = [ "paperless" ];

  services.nginx.virtualHosts = {
    "paperless.fschn.org" = {
      forceSSL = true;
      useACMEHost = "fschn.org";
      locations."/" = {
        proxyPass = "http://localhost:28981";
        proxyWebsockets = true;
      };
    };
    "paperless-gpt.fschn.org" = {
      forceSSL = true;
      useACMEHost = "fschn.org";
      locations."/" = {
        proxyPass = "http://localhost:28983";
        proxyWebsockets = true;
      };
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

  environment.systemPackages = [
    restore-paperless
    pkgs.pass
    pkgs.protonmail-bridge
    pkgs.pinentry-tty
    pkgs.gnupg
  ];


  # BACKUPS
  systemd.tmpfiles.rules = [
    "d ${backupDirDaily} 0750 paperless paperless  -"
    "d ${backupDirMonthly} 0750 paperless paperless  -"
    # Create persistent directories for prompts and config.
    # The upstream paperless-gpt image runs as UID/GID 10001 and must be
    # able to write into /app/prompts and /app/config, so the host mounts
    # are owned by that UID with owner-write permissions.
    "d /var/lib/paperless-gpt 0755 root root -"
    "d /var/lib/paperless-gpt/prompts 0755 10001 10001 -"
    "d /var/lib/paperless-gpt/config 0755 10001 10001 -"
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

  # protonmail bridge for paperless to consume attached documents
  systemd.user.services.protonmail-bridge = {
    description = "Protonmail Bridge";
    enable = true;
    script = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive --log-level info";
    path = [ pkgs.pass ]; # HACK: https://github.com/ProtonMail/proton-bridge/issues/176          
    # after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.Restart = "always";
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };


  #################
  # paperless-gpt #
  #################

  sops.secrets = {
    "paperless-gpt-env" = { };
    "paperless/env" = {
      owner = "paperless";
    };
  };

  virtualisation.oci-containers.containers.paperless-gpt = {
    autoStart = true;
    image = "icereed/paperless-gpt:latest";
    environment = {
      PAPERLESS_BASE_URL = "http://localhost:28981/";
      # Listen on port 28983 (same as previous paperless-ai for continuity)
      LISTEN_INTERFACE = ":28983";
      # Use OpenAI-compatible provider
      LLM_PROVIDER = "openai";
      OPENAI_BASE_URL = "http://rainbow:8080";
      LLM_MODEL = "qwen3.8-27b";
      # LLM-based OCR using the dedicated GLM-OCR vision model.
      OCR_PROVIDER = "llm";
      VISION_LLM_PROVIDER = "openai";
      VISION_LLM_MODEL = "Qwen3-VL-8B-Instruct";
      # Cap OCR-generated output length; prevents runaway vision calls.
      VISION_LLM_MAX_TOKENS = "8192";
      VISION_LLM_TEMPERATURE = "0.2";
      OCR_LIMIT_PAGES = "0";
      LLM_LANGUAGE = "German/English";

      AUTO_OCR_TAG = "paperless-gpt-ocr-auto";
      AUTO_TAG = "paperless-gpt-auto";
      MANUAL_TAG = "paperless-gpt-manual";
      PDF_OCR_TAGGING = "true";
      PDF_OCR_COMPLETE_TAG = "paperless-gpt-ocr-complete";
      PDF_UPLOAD = "false";

      AUTO_GENERATE_TITLE = "true";
      AUTO_GENERATE_TAGS = "true";
      CREATE_NEW_TAGS = "true";
      AUTO_GENERATE_CORRESPONDENTS = "true";
      AUTO_GENERATE_DOCUMENT_TYPE = "true"; # Only existing document types will be used
      AUTO_GENERATE_CREATED_DATE = "true";

      LOG_LEVEL = "debug";
    };
    environmentFiles = [
      config.sops.secrets.paperless-gpt-env.path
    ];
    volumes = [
      # Persistent prompts directory (user customizations saved here)
      "/var/lib/paperless-gpt/prompts:/app/prompts"
      # Persistent config directory (settings.json saved here)
      "/var/lib/paperless-gpt/config:/app/config"
    ];
    # Use host networking so the container listens on the host stack directly;
    extraOptions = [ "--network=host" ];
  };
}
