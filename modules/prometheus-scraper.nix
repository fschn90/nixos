{ config, ... }:

{
    services.prometheus = {
      # ...
      enable = true;
      port = 9090;

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            # targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
            targets = [ "100.106.245.44:9100" ];
          }];
        }
      ];

      # ...
    };
}
