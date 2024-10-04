{ config, pkgs, ... }:

{

  sops.secrets."networking/system-connections/wg-BE-44-P2P.conf" = { };

  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };

  systemd.services.wg = {
    description = "wg network interface";
    bindsTo = [ "netns@wg.service" ];
    requires = [ "network-online.target" ];
    after = [ "netns@wg.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = with pkgs; writers.writeBash "wg-up" ''
        set -e
        ${iproute}/bin/ip link add mywg1 type wireguard
        ${iproute}/bin/ip link set mywg1 netns wg
        ${iproute}/bin/ip -n wg address add 10.2.0.2/32 dev mywg1
        # ${iproute}/bin/ip -n wg -6 address add <ipv6 VPN addr/cidr> dev wg0
        ${iproute}/bin/ip netns exec wg \
          ${wireguard-tools}/bin/wg setconf mywg1 ${toString config.sops.secrets."networking/system-connections/wg-BE-44-P2P.conf".path}
        ${iproute}/bin/ip -n wg link set mywg1 up
        ${iproute}/bin/ip -n wg route add default dev mywg1
        # ${iproute}/bin/ip -n wg -6 route add default dev wg0
      '';
      ExecStop = with pkgs; writers.writeBash "wg-down" ''
        ${iproute}/bin/ip -n wg route del default dev mywg1
        # ${iproute}/bin/ip -n wg -6 route del default dev wg0
        ${iproute}/bin/ip -n wg link del mywg1
      '';
    };
  };


  systemd.services.deluged.bindsTo = [ "netns@wg.service" ];
  systemd.services.deluged.requires = [ "network-online.target" ];
  systemd.services.deluged.after = [ "wg.service" ];
  systemd.services.deluged.serviceConfig.NetworkNamespacePath = [ "/var/run/netns/wg" ];

  systemd.sockets."proxy-to-deluged" = {
    enable = true;
    description = "Socket for Proxy to Deluge Daemon";
    listenStreams = [ "58846" ];
    wantedBy = [ "sockets.target" ];
  };
}
