{ config, ... }:

{
    services.prometheus = {
      # ...

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];

      # ...
    };
}
