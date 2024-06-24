{ pkgs, config, ... }:

{

services.syncoid = {
  enable = true;
  # interval = "daily";
  interval = "*:0/1"; # run this hourly, run syncoid daily to prune ok
  commonArgs = [ "--debug" ];
  commands = {
    "test-home" = {
      sshKey = "/var/lib/syncoid/backup";
      source = "backup@rainbow:NIXROOT/test";
      target = "tank/test-home";
      sendOptions = "w c";
      extraArgs = [ "--sshoption=StrictHostKeyChecking=off" ];
    };
  };
};

  services.sanoid = {
    enable = true;
    interval = "daily"; # run this hourly, run syncoid daily to prune ok
    datasets = {
      "tank/test-home" = {
        autoprune = true;
        autosnap = false;
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
    };

}
