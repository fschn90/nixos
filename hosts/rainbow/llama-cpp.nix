{ pkgs, config, ... }:
{

  services.llama-cpp = {
    enable = true;
    package = pkgs.unstable.llama-cpp-rocm;
  };

  systemd.services.llama-cpp.environment.HSA_OVERRIDE_GFX_VERSION = "11.0.1";

  services.nginx = {
    virtualHosts = {
      "ai.fschn.org" = {
        forceSSL = true;
        useACMEHost = "fschn.org";
        locations."/" = {
          proxyPass = "http://${toString config.services.llama-cpp.host}:${toString config.services.llama-cpp.port}";
          proxyWebsockets = true;
        };
      };
    };
  };

}
