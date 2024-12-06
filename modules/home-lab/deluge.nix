{ config, pkgs, ... }:

{

  services.deluge = {
    enable = true;
    dataDir = "/tank/Deluge";
    authFile = config.sops.secrets."Deluge/Admin".path;
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

  sops.secrets."Deluge/Admin" = {
    path = "/tank/Deluge/authFile";
    owner = "deluge";
    mode = "0440";
  };

  services.nginx = {
    virtualHosts."deluge.fschn.orG" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localHost:${toString config.services.deluge.web.port}";
      };
    };
  };


  # VPN wireguard conf file
  sops.secrets."Deluge/vpn.conf" = { };
  sops.secrets."Deluge/vpn-ip4addr-cidr" = { };

  # creating network namespace
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
    };
  };

  # setting up wireguard interafe within network namespace
  systemd.services.wg = {
    description = "wg network interface";
    bindsTo = [ "netns@wg.service" ];
    requires = [ "network-online.target" ];
    after = [ "netns@wg.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = with pkgs; writers.writeBash "wg-up" ''
        see -e
        ${iproute2}/bin/ip link add wg0 type wireguard
        ${iproute2}/bin/ip link set wg0 netns wg
        ${iproute2}/bin/ip -n wg address add $(cat ${toString config.sops.secrets."Deluge/vpn-ip4addr-cidr".path}) dev wg0
        # ${iproute2}/bin/ip -n wg -6 address add <ipv6 VPN addr/cidr> dev wg0
        ${iproute2}/bin/ip netns exec wg \
          ${wireguard-tools}/bin/wg setconf wg0 ${toString config.sops.secrets."Deluge/vpn.conf".path}
        ${iproute2}/bin/ip -n wg link set wg0 up
        # need to set lo up as network namespace is started with lo down
        ${iproute2}/bin/ip -n wg link set lo up
        ${iproute2}/bin/ip -n wg route add default dev wg0
        # ${iproute2}/bin/ip -n wg -6 route add default dev wg0
      '';
      ExecStop = with pkgs; writers.writeBash "wg-down" ''
        ${iproute2}/bin/ip -n wg route del default dev wg0
        # ${iproute2}/bin/ip -n wg -6 route del default dev wg0
        ${iproute2}/bin/ip -n wg link del wg0
      '';
    };
  };

  # binding deluged to network namespace
  systemd.services.deluged.bindsTo = [ "netns@wg.service" ];
  systemd.services.deluged.requires = [ "network-online.target" "wg.service" ];
  systemd.services.deluged.serviceConfig.NetworkNamespacePath = [ "/var/run/netns/wg" ];

  # allowing delugeweb to access deluged in network namespace, a socket is necesarry 
  systemd.sockets."proxy-to-deluged" = {
    enable = true;
    description = "Socket for Proxy to Deluge Daemon";
    listenStreams = [ "58846" ];
    wantedBy = [ "sockets.target" ];
  };

  # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
  systemd.services."proxy-to-deluged" = {
    enable = true;
    description = "Proxy to Deluge Daemon in Network Namespace";
    requires = [ "deluged.service" "proxy-to-deluged.socket" ];
    after = [ "deluged.service" "proxy-to-deluged.socket" ];
    unitConfig = { JoinsNamespaceOf = "deluged.service"; };
    serviceConfig = {
      User = "deluge";
      Group = "deluge";
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:58846";
      PrivateNetwork = "yes";
    };
  };
}
