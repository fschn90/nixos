{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # hardware specific
    hardware.url = "github:nixos/nixos-hardware";

    #sops-nix
    sops-nix.url = "github:Mic92/sops-nix";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, hardware, sops-nix, ... }@inputs:
    let inherit (self) outputs;
    in {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {

        # LAPTOP
        oide = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/oide/configuration.nix
            hardware.nixosModules.lenovo-thinkpad-t490
            home-manager.nixosModules.home-manager
            { home-manager.users.fschn = import ./homes/portable; }
            sops-nix.nixosModules.sops
          ];
        };

        # DESKTOP
        rainbow = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/rainbow/configuration.nix
            home-manager.nixosModules.home-manager
            { home-manager.users.fschn = import ./homes/fschn; }
            sops-nix.nixosModules.sops
          ];
        };

        # HOME SERVER
        omhe = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/omhe/configuration.nix
            home-manager.nixosModules.home-manager
            { home-manager.users.fschn = import ./homes/headless; }
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
