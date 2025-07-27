{ pkgs, config, ... }:

{

  services.grafana = {
    enable = true;
    settings = {
      analytics.reporting_enabled = false;

      "auth.anonymous".enabled = true;
      "auth.anonymous".org_name = "Main Org.";
      "auth.anonymous".org_role = "Viewer";
      "dashboards".default_home_dashboard_path = "/etc/grafana-dashboards/node-exporter-full_rev40.json"; ## set to node exporter

      server = {
        # Listening Address
        http_addr = "127.0.0.1";
        # protocol = "http";
        # and Port
        http_port = 3001;
        # Grafana needs to know on which domain and URL it's running
        domain = "monitor.fschn.org";
        root_url = "https://monitor.fschn.org/"; # Not needed if it is `https://your.domain/`
        serve_from_sub_path = true;
        enable_gzip = true;
        enforce_domain = true;
      };

      security.admin_password = "$__file{${config.sops.secrets."grafana/admin-password".path}}";

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
          # url = "${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
        }
        # # Some plugins also can - c.f. https://grafana.com/docs/plugins/yesoreyeram-infinity-datasource/latest/setup/provisioning/
        # {
        #   name = "Infinity";
        #   type = "yesoreyeram-infinity-datasource";
        # }
        # # But not all - c.f. https://github.com/fr-ser/grafana-sqlite-datasource/issues/141
      ];

      # Note: removing attributes from the above `datasources.settings.datasources` is not enough for them to be deleted on `grafana`;
      # One needs to use the following option:
      # datasources.settings.deleteDatasources = [ { name = "foo"; orgId = 1; } { name = "bar"; orgId = 1; } ];
    };
  };

  environment.etc = {
    ### Adding a new dashboard?? ###
    ### Read me first
    #  a new dashboard it needs to be imported manually with the grafana web interface and then exported as json first,
    # and only then to be added to the config below. this adds the specific datasource uid to the json.
    "grafana-dashboards/node-exporter-full_rev40.json" = {
      source = ./dashboards/node-exporter-full_rev40.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana-dashboards/logs.json" = {
      source = ./dashboards/logs.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana-dashboards/nextcloud_exporter_rev1.json" = {
      source = ./dashboards/nextcloud_exporter_rev1.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana-dashboards/smartctl_exporter_rev1.json" = {
      source = ./dashboards/smartctl_exporter_rev1.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana-dashboards/Systemd_exporter_rev1.json" = {
      source = ./dashboards/Systemd_exporter_rev1.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana-dashboards/nextcloud_logs_rev4.json" = {
      source = ./dashboards/nextcloud_logs_rev4.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana-dashboards/postgres_rev8.json" = {
      source = ./dashboards/postgres_rev8.json;
      group = "grafana";
      user = "grafana";
    };
    ### Adding a new dashboard?? ###
    ### Adding a new dashboard?? ###
    ### Adding a new dashboard?? ###
  };

  services.nginx.virtualHosts."monitor.fschn.org" = {
    addSSL = true; # important: addSSL not foreSSL
    useACMEHost = "fschn.org";
    locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };

  sops.secrets."grafana/admin-password" = {
    owner = "grafana";
  };



}
