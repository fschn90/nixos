{ config, ... }:

{
  services.prometheus = {
    enable = true;
    port = 9090;

    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "15s"; # Necessary for the Node Exporter Dashbaord to fully work, not showing no data in some graphs when time selected is smaller than 24h 
        static_configs = [{
          targets = [
            "omhe:${toString config.services.prometheus.exporters.node.port}"
            "rainbow:${toString config.services.prometheus.exporters.node.port}"
            "oide:${toString config.services.prometheus.exporters.node.port}"
            "berry:${toString config.services.prometheus.exporters.node.port}"
            "helio:${toString config.services.prometheus.exporters.node.port}"
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
            "berry:${toString config.services.prometheus.exporters.nginx.port}"
            "helio:${toString config.services.prometheus.exporters.nginx.port}"
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
            "berry:${toString config.services.prometheus.exporters.smartctl.port}"
            "helio:${toString config.services.prometheus.exporters.smartctl.port}"
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
      {
        job_name = "process";
        static_configs = [{
          targets = [
            "omhe:${toString config.services.prometheus.exporters.process.port}"
            "rainbow:${toString config.services.prometheus.exporters.process.port}"
            "oide:${toString config.services.prometheus.exporters.process.port}"
            "berry:${toString config.services.prometheus.exporters.process.port}"
            "helio:${toString config.services.prometheus.exporters.process.port}"
          ];
        }];
      }
      {
        job_name = "systemd";
        static_configs = [{
          targets = [
            "omhe:${toString config.services.prometheus.exporters.systemd.port}"
            "rainbow:${toString config.services.prometheus.exporters.systemd.port}"
            "oide:${toString config.services.prometheus.exporters.systemd.port}"
            "berry:${toString config.services.prometheus.exporters.systemd.port}"
            "helio:${toString config.services.prometheus.exporters.systemd.port}"
          ];
        }];
      }
      {
        job_name = "postgres_exporter";
        static_configs = [{
          targets = [
            "omhe:${toString config.services.prometheus.exporters.postgres.port}"
          ];
        }];
      }
      {
        job_name = "deluge";
        static_configs = [{
          targets = [
            "omhe:${toString config.services.prometheus.exporters.deluge.port}"
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
