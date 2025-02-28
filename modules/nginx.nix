{
  services.nginx = {
    enable = true;
    statusPage = true; # for monitoring
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    logError = "stderr debug";
  };
}
