{ config, lib, pkgs, ... }:

{
  services.tor = {
    enable = true;

    # Bridge only: no local SOCKS client or torsocks
    client.enable = false;
    torsocks.enable = false;

    # Keep GeoIP on: bridges use it for aggregated, privacy-preserving usage stats
    enableGeoIP = true;

    relay = {
      enable = true;
      role = "bridge";
    };

    settings = {
      Nickname = "torbridgeuniformly6";
      ContactInfo = "tor-bridge.uniformly698@passmail.net";

      # ~1/3 of the 50 Mbit/s upload (50 / 3 ≈ 16.7 Mbit/s).
      # Tor's limit is symmetric, so upload sets the ceiling.
      # "MBits" = megabits/s; "MB" in your original meant megaBYTES/s (~1,600 Mbit/s).
      RelayBandwidthRate = "16 MBits";
      RelayBandwidthBurst = "24 MBits"; # set equal to the rate for a hard cap

      # Resource tuning for a 4 GB Pi
      NumCPUs = 2;
      MaxMemInQueues = "1 GB";
      AvoidDiskWrites = 1;
      SafeLogging = 1;

      ORPort = [
        {
          port = 2222;
          flags = [ "IPv4Only" ]; # remove if you have working IPv6
        }
      ];

      # obfs4 makes the bridge much harder to block.
      # Check the binary name: lyrebird (recent nixpkgs) or obfs4proxy (older)
      ServerTransportPlugin = {
        transports = [ "obfs4" ];
        exec = "${pkgs.obfs4}/bin/lyrebird";
      };
      ServerTransportListenAddr = "obfs4 0.0.0.0:8443";

      # Optional monthly cap if your ISP meters traffic
      # AccountingStart = "month 1 00:00";
      # AccountingMax = "2 TBytes";
    };
  };

  # Also forward both ports on your router
  networking.firewall.allowedTCPPorts = [ 2222 8443 ];

  # Snowflake has no rate limiter and shares the same uplink, so keep it modest
  services.snowflake-proxy = {
    enable = true;
    capacity = 50;
  };

  zramSwap.enable = true;
}
