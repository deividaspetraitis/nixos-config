{
  description = "My Awesome System Config";

  # This is the standard format for flake.nix.
  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Official NixOS package source, using 25.05 branch here
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # Opnixs is a secure integration between 1Password and NixOS for managing secrets 
    # during system builds and home directory setup.
    opnix.url = "github:brizzbuzz/opnix";

    # 1Password Shell Plugins allows securely authenticate third-party CLIs with fingerprint, Apple Watch, or system authentication.
    # CLI credentials are stored in 1Password account, so you never have to manually enter your credentials or store them in plaintext.
    _1password-shell-plugins.url = "github:1Password/shell-plugins";

    # Nix hardware quirks channel.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  # `outputs` are all the build result of the flake.
  #
  # A flake can have many use cases and different types of outputs.
  # 
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  # 
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = { self, nixpkgs, nixpkgs-stable, opnix, nixos-hardware, home-manager, ... } @ inputs:
    let
      # Target system
      system = "x86_64-linux";

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

      # Setup packages
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [ overlay-stable ];
      };

      inherit (self) outputs;

    in
    {
      nixosConfigurations = {
        # By default, NixOS will try to refer the nixosConfiguration with
        # its hostname, so the system named `nixos-test` will use this one.
        # However, the configuration name can also be specified using:
        #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
        #
        # The `nixpkgs.lib.nixosSystem` function is used to build this
        # configuration, the following attribute set is its parameter.
        #
        # Run the following command in the flake's directory to
        # deploy this configuration on any NixOS system:
        #   sudo nixos-rebuild switch --flake .#nixos-test
        "am4" = nixpkgs.lib.nixosSystem {
          inherit system;
          # nixpkgs = nixpkgs;

          # The Nix module system can modularize configuration,
          # improving the maintainability of configuration.
          #
          # Each parameter in the `modules` is a Nix Module, and
          # there is a partial introduction to it in the nixpkgs manual:
          #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
          # It is said to be partial because the documentation is not
          # complete, only some simple introductions.
          # such is the current state of Nix documentation...
          #
          # A Nix Module can be an attribute set, or a function that
          # returns an attribute set. By default, if a Nix Module is a
          # function, this function have the following default parameters:
          #
          #  lib:     the nixpkgs function library, which provides many
          #             useful functions for operating Nix expressions:
          #             https://nixos.org/manual/nixpkgs/stable/#id-1.4
          #  config:  all config options of the current flake, very useful
          #  options: all options defined in all NixOS Modules
          #             in the current flake
          #  pkgs:   a collection of all packages defined in nixpkgs,
          #            plus a set of functions related to packaging.
          #            you can assume its default value is
          #            `nixpkgs.legacyPackages."${system}"` for now.
          #            can be customed by `nixpkgs.pkgs` option
          #  modulesPath: the default path of nixpkgs's modules folder,
          #               used to import some extra modules from nixpkgs.
          #               this parameter is rarely used,
          #               you can ignore it for now.
          #
          # The default parameters mentioned above are automatically
          # generated by Nixpkgs. 
          # However, if you need to pass other non-default parameters
          # to the submodules, 
          # you'll have to manually configure these parameters using
          # `specialArgs`. 
          # you must use `specialArgs` by uncomment the following line:
          #
          # specialArgs = {...};  # pass custom arguments into all sub module.
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-stable ]; })
            opnix.nixosModules.default
            ./hosts/am4/configuration.nix
          ];
        };

        "helix" = nixpkgs.lib.nixosSystem {
          inherit system;
          # nixpkgs = nixpkgs;

          # The Nix module system can modularize configuration,
          # improving the maintainability of configuration.
          #
          # Each parameter in the `modules` is a Nix Module, and
          # there is a partial introduction to it in the nixpkgs manual:
          #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
          # It is said to be partial because the documentation is not
          # complete, only some simple introductions.
          # such is the current state of Nix documentation...
          #
          # A Nix Module can be an attribute set, or a function that
          # returns an attribute set. By default, if a Nix Module is a
          # function, this function have the following default parameters:
          #
          #  lib:     the nixpkgs function library, which provides many
          #             useful functions for operating Nix expressions:
          #             https://nixos.org/manual/nixpkgs/stable/#id-1.4
          #  config:  all config options of the current flake, very useful
          #  options: all options defined in all NixOS Modules
          #             in the current flake
          #  pkgs:   a collection of all packages defined in nixpkgs,
          #            plus a set of functions related to packaging.
          #            you can assume its default value is
          #            `nixpkgs.legacyPackages."${system}"` for now.
          #            can be customed by `nixpkgs.pkgs` option
          #  modulesPath: the default path of nixpkgs's modules folder,
          #               used to import some extra modules from nixpkgs.
          #               this parameter is rarely used,
          #               you can ignore it for now.
          #
          # The default parameters mentioned above are automatically
          # generated by Nixpkgs. 
          # However, if you need to pass other non-default parameters
          # to the submodules, 
          # you'll have to manually configure these parameters using
          # `specialArgs`. 
          # you must use `specialArgs` by uncomment the following line:
          #
          # specialArgs = {...};  # pass custom arguments into all sub module.
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-stable ]; })
            opnix.nixosModules.default
            ./hosts/helix/configuration.nix
          ];
        };

        "darwin" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Overlays-module makes "pkgs.unstable" available in configuration.nix
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-stable ]; })
            nixos-hardware.nixosModules.apple-t2

            ./hosts/darwin/configuration.nix
          ];
        };
      };

      homeManagerConfigurations = {
        deividas = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = { inherit pkgs-stable inputs outputs; };
          pkgs = pkgs;
          modules = [
            opnix.homeManagerModules.default
            ./users/deividas/home.nix
          ];
        };
      };
    };
}
