{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: _: prev: {
      # this allows you to access `pkgs.unstable` anywhere in your config
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };
      # linux-firmware = prev.linux-firmware.overrideAttrs rec {
      #   version = "20250311";
      #   src = prev.fetchzip {
      #     url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${version}.tar.xz ";
      #     hash = "sha256-ZM7j+kUpmWJUQdAGbsfwOqsNV8oE0U2t6qnw0b7pT4g=";
      #   };
      # };
    })
  ];
}
