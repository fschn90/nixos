{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: _: {
      # this allows you to access `pkgs.unstable` anywhere in your config
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };
    })
    ## skipping check phase for valkey as a test keeps failling: 15.05.26 TODO remove in one month and see if it build without test fails 
    (final: prev: {
      valkey = prev.valkey.overrideAttrs (_: { doCheck = false; });
    })
  ];


}
