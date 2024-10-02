{ pkgs, config, options, ... }:

# currently omhe

{

  services.syncoid = {
    enable = true;
    interval = "*-*-* 00/2:30:00";
    commonArgs = [ "--debug" ];
    commands = {
      "rainbow" = {
        sshKey = "/var/lib/syncoid/backup";
        source = "backup@rainbow:NIXROOT/home";
        target = "tank/rainbow-backup";
        sendOptions = "w c";
        extraArgs = [ "--sshoption=StrictHostKeyChecking=off" ];
      };
      "oide" = {
        sshKey = "/var/lib/syncoid/backup";
        source = "backup@oide:NIXROOT/home";
        target = "tank/oide-backup";
        sendOptions = "w c";
        extraArgs = [ "--sshoption=StrictHostKeyChecking=off" ];
      };
    };

    # necesary to prune old snapshots: https://github.com/NixOS/nixpkgs/issues/216614
    localSourceAllow = options.services.syncoid.localSourceAllow.default ++ [
      "mount"
    ];
    localTargetAllow = options.services.syncoid.localTargetAllow.default ++ [
      "destroy"
    ];
  };

  services.sanoid = {
    enable = true;
    interval = "hourly"; # run this hourly, run syncoid daily to prune ok
    datasets = {
      "tank/rainbow-backup" = {
        autoprune = true;
        autosnap = false;
        hourly = 24;
        daily = 31;
        weekly = 7;
        monthly = 12;
        yearly = 2;
      };
      "tank/oide-backup" = {
        autoprune = true;
        autosnap = false;
        hourly = 24;
        daily = 31;
        weekly = 7;
        monthly = 12;
        yearly = 2;
      };
      "tank/Nextcloud" = {
        autoprune = true;
        autosnap = true;
        hourly = 24;
        daily = 31;
        weekly = 7;
        monthly = 12;
        yearly = 2;
      };
      "tank/Jellyfin" = {
        autoprune = true;
        autosnap = true;
        hourly = 24;
        daily = 31;
        weekly = 7;
        monthly = 12;
        yearly = 2;
      };
    };
    extraArgs = [ "--debug" ];
  };


  environment.systemPackages = with pkgs; [
    # used by zfs send/receive
    pv
    mbuffer
    lzop
    zstd
  ];

  sops.secrets."ssh/keys/backup" = {
    mode = "0600";
    path = "/var/lib/syncoid/backup";
    owner = "syncoid";
  };

} 
