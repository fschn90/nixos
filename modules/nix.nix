{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # nix store garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "monthly";
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "monthly" ];
}
