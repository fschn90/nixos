{ config, ... }:

{

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."paperless/admin-password".path;
    consumptionDirIsPublic = true;
    # address = "paperless.fschn.org";
    dataDir = "/tank/Paperless";
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      # PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
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

}
