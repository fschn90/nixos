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

  services.prometheus.exporters.zfs.enable = true;
  services.prometheus.exporters.nginx.enable = true;
  # services.prometheus.exporters.nginxlog.enable = true;
  services.prometheus.exporters.smartctl.enable = true;
  

}
