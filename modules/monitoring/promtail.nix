{ config, ... }:

{

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3031;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [
        {
          # url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          # url = "http://100.106.245.44:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          url = "http://100.106.245.44:3030/loki/api/v1/push";
        }
      ];
      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = "${builtins.toString config.networking.hostName}";
          };
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }
        {
          job_name = "system";
          static_configs = [{
            # targets = [ "localhost" ];
            targets = [ "100.106.245.44" ];
            labels = {
              instance = "nextcloud.fschn.org";
              env = "home-lab";
              job = "nextcloud";
              __path__ = "/tank/Nextcloud/data/{nextcloud,audit}.log";
            };
          }];
        }];
    };
    # extraFlags
  };

}
