{ config, pkgs, ... }:

{

  services.deluge = {
    enable = true;
    # dataDir = "/tank/Deluge";
    # authFile = config.sops.secrets."Deluge/Admin".path;
    # declarative = true;
    # config = 
    #   {
    #     download_location = "/srv/torrents/";
    #     max_upload_speed = "1000.0";
    #     share_ratio_limit = "2.0";
    #     allow_remote = true;
    #     daemon_port = 58846;
    #     listen_ports = [ 6881 6889 ];
    #   };
    web.enable = true;
  };

  # sops.secrets."Deluge/Admin" = {
  #   path = "/tank/Deluge/authFile";
  #   owner = "deluge";
  #   mode = "0440";
  # };

  # services.nginx = {
  #   virtualHosts."deluge.fschn.org" = {
  #     useACMEHost = "fschn.org";
  #     forceSSL = true;
  #     locations."/" = {
  #       proxyPass = "http://localhost:${toString config.services.deluge.web.port}";
  #     };
  #   };
  # };


  # sops.secrets."networking/system-connections/wg-BE-44-P2P.conf" = {
  #   mode = "0600";
  #   path = "/etc/NetworkManager/system-connections/wg-BE-44-P2P.conf";
  # };

  # systemd.services."netns@" = {
  #   description = "%I network namespace";
  #   before = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.iproute}/bin/ip netns add %I";
  #     ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
  #   };
  # };

  # systemd.services.wg = {
  #   description = "wg network interface";
  #   bindsTo = [ "netns@wg.service" ];
  #   requires = [ "network-online.target" ];
  #   after = [ "netns@wg.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = with pkgs; writers.writeBash "wg-up" ''
  #       set -e
  #       ${iproute}/bin/ip link add wg0 type wireguard
  #       ${iproute}/bin/ip link set wg0 netns wg
  #       ${iproute}/bin/ip -n wg address add <ipv4 VPN addr/cidr> dev wg0
  #       ${iproute}/bin/ip -n wg -6 address add <ipv6 VPN addr/cidr> dev wg0
  #       ${iproute}/bin/ip netns exec wg \
  #         ${wireguard-tools}/bin/wg setconf wg0 ${toString config.sops.secrets."networking/system-connections/wg-BE-44-P2P.conf".path}
  #       ${iproute}/bin/ip -n wg link set wg0 up
  #       ${iproute}/bin/ip -n wg route add default dev wg0
  #       ${iproute}/bin/ip -n wg -6 route add default dev wg0
  #     '';
  #     ExecStop = with pkgs; writers.writeBash "wg-down" ''
  #       ${iproute}/bin/ip -n wg route del default dev wg0
  #       ${iproute}/bin/ip -n wg -6 route del default dev wg0
  #       ${iproute}/bin/ip -n wg link del wg0
  #     '';
  #   };
  # };
}
