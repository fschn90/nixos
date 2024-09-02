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
          static_configs = [
            {
              targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.zfs.port}" ];
            }
          ];
        }
      ];
    };
}
