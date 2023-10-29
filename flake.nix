{
  description = "My Awesome System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: 
  let
    # Target system
    system = "x86_64-linux";

    # Setup packages
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;

        modules = [
          ./system/configuration.nix
        ];
      };
    };

    homeManagerConfigurations = {
      deividas = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          ./users/deividas/home.nix
        ];
      };
    };
  };
}
