{ pkgs, config, ... }:

{

  services.grafana = {
    enable = true;
    settings = {
      server = {
        # Listening Address
        http_addr = "100.106.245.44";
        # and Port
        http_port = 3001;
        # Grafana needs to know on which domain and URL it's running
        domain = "grafana.fschn.org";
        root_url = "https://grafana.fschn.org/"; # Not needed if it is `https://your.domain/`
        serve_from_sub_path = true;
      };
    };
  };

  services.grafana = {
    # declarativePlugins = with pkgs.grafanaPlugins; [ ... ];

    provision = {
      enable = true;

      dashboards.settings.providers = [{
        name = "my dashboards";
        options.path = "/etc/grafana-dashboards";
      }];

      datasources.settings.datasources = [
        # "Built-in" datasources can be provisioned - c.f. https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources
        {
          name = "Prometheus";
          type = "prometheus";
          url = "${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
        }
        # # Some plugins also can - c.f. https://grafana.com/docs/plugins/yesoreyeram-infinity-datasource/latest/setup/provisioning/
        # {
        #   name = "Infinity";
        #   type = "yesoreyeram-infinity-datasource";
        # }
        # But not all - c.f. https://github.com/fr-ser/grafana-sqlite-datasource/issues/141
      ];

      # Note: removing attributes from the above `datasources.settings.datasources` is not enough for them to be deleted on `grafana`;
      # One needs to use the following option:
      # datasources.settings.deleteDatasources = [ { name = "foo"; orgId = 1; } { name = "bar"; orgId = 1; } ];
    };
  };

  environment.etc = {
    "grafana-dashboards/node-exporter-full_rev37.json" = {
      source = ../node-exporter-full_rev37.json;
      group = "grafana";
      user = "grafana";
    };
  };

  services.nginx.virtualHosts."grafana.fschn.org" = {
    forceSSL = true;
    useACMEHost = "fschn.org";
    locations."/" = {
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
  };

}
