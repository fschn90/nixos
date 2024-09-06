{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "logind"
      "systemd"
    ];
    extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi" ];
    disabledCollectors = [
      "textfile"
    ];
    # openFirewall = true;
    # firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
  };

  services.prometheus.exporters.zfs.enable = true;
  services.prometheus.exporters.nginx.enable = true;
  services.prometheus.exporters.nginxlog.enable = true;
  

}
