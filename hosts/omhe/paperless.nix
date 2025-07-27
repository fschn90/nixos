{ config, ... }:

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
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_CONSUMER_DELETE_DUPLICATES = true;
      # PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
      PAPERLESS_URL = "https://paperless.fschn.org"; # neccessary to avoid error: [WARNING] [django.security.csrf] Forbidden (Origin checking failed - https://paperless.fschn.org does not match any trusted origins.): /accounts/login/
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

  systemd.tmpfiles.rules = [
    "d /tank/Paperless/backups 0770 postgres postgres  -"
  ];


  services.postgresqlBackup = {
    enable = true;
    databases = [ "paperless" ];
    location = "/tank/Paperless/backup";
    compressionLevel = 11;
  };
}
