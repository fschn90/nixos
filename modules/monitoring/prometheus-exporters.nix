{ config, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "logind"
      "systemd"
      "ethtool"
      "softirqs"
      "tcpstat"
      "wifi"
      "processes"
      "cpu"
      "loadavg"
      "filesystem"
      "interrupts"
      "zfs"
      "drm"
      "powersupplyclass"
      # "logind"
    ];
    # extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi" "--collector.processes" ];
    disabledCollectors = [
      "textfile"
    ];
    # openFirewall = true;
    # firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
  };

  services.prometheus.exporters.process.enable = true;
  services.prometheus.exporters.systemd.enable = true;

  # services.prometheus.exporters.zfs.enable = true;
  # services.prometheus.exporters.nginx.enable = true;
  # # services.prometheus.exporters.nginxlog.enable = true;
  # services.prometheus.exporters.smartctl.enable = true;
  # services.prometheus.exporters.nextcloud = {
  #   enable = true;
  #   tokenFile = config.sops.secrets."Nextcloud/authToken".path;
  #   url = "https://${builtins.toString config.services.nextcloud.hostName}";
  #   # to avoid time out errors in the beginning, seems to be running much faster now, maybe not needed anymore, ie default value enough
  #   timeout = "60s";
  #   extraFlags = [
  #     "--tls-skip-verify true"
  #   ];
  # };

  # # make sure nextcloud-exporter has access to secret
  # users.users.nextcloud-exporter.extraGroups = [ "nextcloud" ];

  # # secret deployment for nextcloud-exporter
  # sops.secrets."Nextcloud/authToken" = {
  #   path = "/tank/Nextcloud/authToken";
  #   owner = "nextcloud";
  #   mode = "0440";
  # };

}
