{ config, ... }:

{

  services.deluge = {
    enable = true;
    dataDir = "/tank/Deluge";
    authFile = config.sops.secrets."Deluge/Admin".path;
    # declarative = true;
    # config = 
    #   {
    #     download_location = "/srv/torrents/";
    #     max_upload_speed = "1000.0";
    #     share_ratio_limit = "2.0";
    #     allow_remote = true;
    #     daemon_port = 58846;
    #     listen_ports = [ 6881 6889 ];
    #   };
    web.enable = true;
  };

  sops.secrets."Deluge/Admin" = {
    path = "/tank/Deluge/authFile";
    owner = "deluge";
    mode = "0440";
  };


  services.nginx = {
    virtualHosts."deluge.fschn.org" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.deluge.web.port}";
      };
    };
  };
}
