{

  services.coredns.enable = true;
  services.coredns.config =
  ''
    . {
      # Cloudflare
      forward . tls://1.1.1.1 tls://1.0.0.1
      cache
    }

    home {
      template IN A  {
          answer "{{ .Name }} 0 IN A 100.106.245.44"
      }
    }
  '';

}
