{ pkgs, ... }:

{

  services.sanoid = {
    enable = true;
    interval = "hourly"; # run this hourly, run syncoid daily to prune ok
    datasets = {
      "NIXROOT/home" = {
        autoprune = true;
        autosnap = true;
        hourly = 24;
        daily = 31;
        weekly = 1;
        monthly = 1;
        yearly = 1;
      };
    };
    extraArgs = [ "--debug" ];
  };

  users.users.backup = {
    isNormalUser = true;
    createHome = false;
    home = "/var/empty";
    extraGroups = [ ];
    openssh = {
      authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMg2AFhpk8nsyxXSRLnSaEWXDQFQzCEsw+TsQsK/Hi9U fschn@rainbow''
      ];
    };
  };

  
environment.systemPackages = with pkgs; [
  # used by zfs send/receive
  pv
  mbuffer
  lzop
  zstd
];

}
