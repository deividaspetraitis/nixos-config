{
  description = "My Awesome System Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-23.05";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixpkgs-stable, home-manager, ... }: 
  let
    # Target system
    system = "x86_64-linux";

    # Setup packages
    pkgs = import nixpkgs {
      inherit system;
      config = { 
        allowUnfree = true;
      };
    };

    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config = { allowUnfree = true; };
    };

    overlay-stable = final: prev: {
        stable = import nixpkgs-stable {
        inherit system;
        config = { allowUnfree = true; };
      };
    };

    lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-stable ]; })
          ./system/configuration.nix
        ];
      };
    };

    homeManagerConfigurations = {
      deividas = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit pkgs-stable; };
        pkgs = pkgs;
        modules = [
          ./users/deividas/home.nix
        ];
      };
    };
  };
}
