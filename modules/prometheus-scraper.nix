{ config, ... }:

{
    services.prometheus = {
      # ...
      enable = true;
      port = 9090;
      # listenAddress = "127.0.0.1";

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
            # targets = [ "100.106.245.44:9100" ];
          }];
        }
        {
          job_name = "node_oide";
          static_configs = [{
            # targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
            targets = [ "100.79.181.86:9100" ];
          }];
        }
      ];

      # ...
    };
}
