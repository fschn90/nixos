{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # hardware specific
    hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, hardware, ... }@inputs:
    let inherit (self) outputs;
    in {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # LAPTOP
        nix-fschn = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/oide/configuration.nix
            ./hosts/oide/t490-nvidia.nix
            ./modules/sound.nix
            ./modules/bluetooth.nix
            home-manager.nixosModules.home-manager
            hardware.nixosModules.lenovo-thinkpad-t490
            { home-manager.users.fschn = import ./homes/fschn; }

          ];
        };

        # DESKTOP
        fschn = nixpkgs.lib.nixosSystem {
              specialArgs = { inherit inputs outputs; };
              modules = [
                ./hosts/rainbow/configuration.nix
                ./hosts/rainbow/amd.nix
                ./modules/sound.nix
                ./modules/bluetooth.nix
                home-manager.nixosModules.home-manager
                { home-manager.users.fschn = import ./homes/fschn; }

              ];
            };
      };
    };
}
