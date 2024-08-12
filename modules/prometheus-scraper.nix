{ config, ... }:

{
    services.prometheus = {
      enable = true;
      port = 9090;

      scrapeConfigs = [
        {
          job_name = "node_omhe";
          static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
        {
          job_name = "node_oide";
          static_configs = [{
            targets = [ "100.79.181.86:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
        {
          job_name = "node_rainbow";
          static_configs = [{
            targets = [ "100.114.14.104:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };
}
