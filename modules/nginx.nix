{

  services.tailscaleAuth.enable = true;

  services.nginx = {
    enable = true;
    statusPage = true; # for monitoring
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    # logError = "stderr debug";
    tailscaleAuth.virtualHosts = [
      "adguard.fschn.org"
      "monitor.fschn.org"
      "photos.fschn.org"
      "jellyfin.fschn.org"
      "cloud.fschn.org"
      "deluge.fschn.org"
      "paperless.fschn.org"
      "ai.fschn.org"
    ];
    tailscaleAuth.enable = true;
  };
}
