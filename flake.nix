{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
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
            { home-manager.users.fschn = import ./homes/fschn; }
            # sops-nix.nixosModules.sops
            # sops-nix.homeManagerModules.sops
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
            # sops-nix.homeManagerModules.sops
          ];
        };
      };
    };
}
