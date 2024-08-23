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

      ];
    };
}
