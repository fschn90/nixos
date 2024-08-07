{ config, ...}:

{
  
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "hello@fschn.org";
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.defaults.dnsResolver = "1.1.1.1:53";
  security.acme.defaults.environmentFile = config.sops.secrets."cloudflare/dns-api".path;
  security.acme.defaults.dnsPropagationCheck = true;

  security.acme.certs."fschn.org" = {
    domain = "*.fschn.org";
    group = "nginx";
    reloadServices = [ "nginx" ];
  };

  sops.secrets."cloudflare/dns-api" = {
  };

   users.users.nginx.extraGroups = [ "acme" ];
  
}
