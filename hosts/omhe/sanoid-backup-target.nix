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
        weekly = 7;
        monthly = 12;
        yearly = 2;
      };
    };
    extraArgs = [ "--debug" ];
  };


}
