{

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.GatewayPorts = "yes";
  # services.openssh.settings.X11Forwarding = true;

}
