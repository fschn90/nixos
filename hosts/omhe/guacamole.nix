{ pkgs, config, lib, ... }:

{

  services.guacamole-server = {
    enable = true;
    host = "0.0.0.0";
    userMappingXml = config.sops.secrets."guacamole/user-mapping.xml".path;
    package = pkgs.unstable.guacamole-server; # Optional, use only when you want to use the unstable channel
  };

  services.guacamole-client = {
    enable = true;
    enableWebserver = true;
    settings = {
      guacd-port = 4822;
      guacd-hostname = "0.0.0.0";
    };
    package = pkgs.unstable.guacamole-client; # Optional, use only when you want to use the unstable channel
  };

  sops.secrets."guacamole/user-mapping.xml" = {
    mode = "644";
  };

  # to avoid port conflict with open-webui on port 8080
  services.tomcat.port = 8079;

  #nginx configuration from wiki.nixos.org/wiki/Remote_Desktop
  services.nginx = {
    enable = true;
    upstreams."guacamole_server" = {
      extraConfig = ''
        keepalive 4;
      ''
      ;
      servers = {
        "0.0.0.0:8079" = { };
      };
    };
    virtualHosts."remote.fschn.org" = {
      forceSSL = true; # redirect http to https
      useACMEHost = "fschn.org";
      # enableACME = true;
      locations."/" = {
        extraConfig = ''
          proxy_buffering off;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $http_connection;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $host;
          proxy_set_header X-NginX-Proxy true;
          proxy_pass http://guacamole_server/guacamole$request_uri;
          proxy_redirect http://guacamole_server/ https://$server_name/;
        '';
      };
    };
  };

  # making sure DejaVuSansMono is available
  fonts.packages = with pkgs; [
    dejavu_fonts
  ];

  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = "remote.fschn.org";
      answer = "${toString config.tailnet.omhe}";
    }
  ];

  services.openssh.settings.PasswordAuthentication = lib.mkForce true;

}
