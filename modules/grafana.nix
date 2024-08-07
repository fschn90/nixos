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
        root_url = "https://grafana.fschn.org/grafana/"; # Not needed if it is `https://your.domain/`
        serve_from_sub_path = true;
      };
    };
  };

  services.nginx.virtualHosts."grafana.fschn.org" = {
  forceSSL = true;
  useACMEHost = "fschn.org";
  locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      # recommendedProxySettings = true;
  };
};

}
