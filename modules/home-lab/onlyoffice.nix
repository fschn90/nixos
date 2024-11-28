{ config, ... }:

{

  services.onlyoffice = {
    enable = true;
    jwtSecretFile = config.sops.secrets."onlyoffice/jwtSecretFile".path;
    hostname = "office.fschn.org";
  };

  # reverse proxy
  services.nginx = {
    # virtualHosts."office.fschn.org" = {
    virtualHosts.${config.services.onlyoffice.hostname} = {
      useACMEHost = "fschn.org";
      forceSSL = true;
    };
  };

  # secret deployment
  sops.secrets."onlyoffice/jwtSecretFile" = {
    owner = "onlyoffice";
  };

}
