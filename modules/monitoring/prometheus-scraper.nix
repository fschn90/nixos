{ config, ... }:

{
    services.prometheus = {
      enable = true;
      port = 9090;

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ 
              "omhe:${toString config.services.prometheus.exporters.node.port}" 
              "rainbow:${toString config.services.prometheus.exporters.node.port}" 
              "oide:${toString config.services.prometheus.exporters.node.port}" 
            ];
          }];
        }
        {
          job_name = "zfs";
          static_configs = [{
            targets = [ 
              "omhe:${toString config.services.prometheus.exporters.zfs.port}" 
              "rainbow:${toString config.services.prometheus.exporters.zfs.port}" 
              "oide:${toString config.services.prometheus.exporters.zfs.port}" 
            ];
          }];
        }
        {
          job_name = "nginx";
          static_configs = [{
            targets = [ 
              "omhe:${toString config.services.prometheus.exporters.nginx.port}" 
              "rainbow:${toString config.services.prometheus.exporters.nginx.port}" 
              "oide:${toString config.services.prometheus.exporters.nginx.port}" 
            ];
          }];
        }
        # {
        #   job_name = "nginxlog";
        #   static_configs = [{
        #     targets = [ 
        #       "omhe:${toString config.services.prometheus.exporters.nginxlog.port}" 
        #       "rainbow:${toString config.services.prometheus.exporters.nginxlog.port}" 
        #       "oide:${toString config.services.prometheus.exporters.nginxlog.port}" 
        #     ];
        #   }];
        # }
        {
          job_name = "smartctl";
          static_configs = [{
            targets = [ 
              "omhe:${toString config.services.prometheus.exporters.smartctl.port}" 
              "rainbow:${toString config.services.prometheus.exporters.smartctl.port}" 
              "oide:${toString config.services.prometheus.exporters.smartctl.port}" 
            ];
          }];
        }
        {
          job_name = "nextcloud";
          # to avoid time out errors in the beginning, seems to be running much faster now, maybe not needed anymore, ie default value enough
          scrape_timeout = "60s";
          static_configs = [{
            targets = [ 
              "omhe:${toString config.services.prometheus.exporters.nextcloud.port}" 
            ];
          }];
        }

      ];
    };

  services.nginx = {
    virtualHosts."prometheus.fschn.org" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${builtins.toString config.services.prometheus.port}";
      };
    };
  };

}
