{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # nix store garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.optimise.automatic = true;
  nix.optimise.dates = ["weekly"];
}
