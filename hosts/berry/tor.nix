{
  services.tor = {
    enable = true;

    # Disable GeoIP to prevent the Tor client from estimating the locations of Tor nodes it connects to
    enableGeoIP = false;

    # Enable Torsocks for transparent proxying of applications through Tor
    torsocks.enable = true;

    # Enable the Tor client
    client = {
      enable = true;
    };

    # Enable and configure the Tor relay
    relay = {
      enable = true;
      role = "bridge"; # Set the relay role (e.g., "relay", "bridge")
    };

    # Configure Tor settings
    settings = {
      Nickname = "tor-bridge.uniformly698";
      ContactInfo = "tor-bridge.uniformly698@passmail.net";

      # Bandwidth settings
      MaxAdvertisedBandwidth = "100 MB";
      BandWidthRate = "50 MB";
      RelayBandwidthRate = "50 MB";
      RelayBandwidthBurst = "100 MB";

      # Restrict exit nodes to a specific country (use the appropriate country code)
      ExitNodes = "{ch} StrictNodes 1";

      # Reject all exit traffic
      ExitPolicy = "reject *:*";

      # Performance and security settings
      CookieAuthentication = true;
      AvoidDiskWrites = 1;
      HardwareAccel = 1;
      SafeLogging = 1;
      NumCPUs = 3;

      # Network settings
      ORPort = [ 443 ];
    };
  };

  # Operating a Snowflake proxy helps others circumvent censorship. Safe to run.
  services.snowflake-proxy = {
    enable = true;
    capacity = 10;
  };

}
