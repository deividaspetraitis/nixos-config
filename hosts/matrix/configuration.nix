# configuration.nix

{ pkgs, config, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    raspberry-pi."4".poe-plus-hat.enable = true;
    deviceTree = {
      enable = true;
      filter = "bcm2711-rpi-4*.dtb";
    };
  };

  # Poe-HAT fans are annoyingly loud and can be managed only declaratively, not via /boot/config.txt even if docs state otherwise.
  # See docs: https://github.com/raspberrypi/linux/blob/590178d58b730e981099fdcb405053a000e79820/arch/arm/boot/dts/overlays/README#L4493
  # See source: https://github.com/NixOS/nixos-hardware/blob/cce68f4a54fa4e3d633358364477f5cc1d782440/raspberry-pi/4/poe-plus-hat.nix#L8
  # This overlay customizes the fan speed levels and thermal trip points for the PoE+ HAT fan.
  # Note: merge by symbols doesn't work for some reason, so we have to override by path.
  hardware.deviceTree.overlays = lib.mkAfter [
    {
      name = "poe-plus-tune";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "brcm,bcm2711";

          /* override the node created by the poe overlay by its path */
          fragment@0 {
            target-path = "/pwm-fan";
            __overlay__ {
              cooling-levels = <0 16 64 160 255>;
            };
          };

          /* override trips by path too */
          fragment@1 {
            target-path = "/thermal-zones/cpu-thermal/trips/trip0";
            __overlay__ { temperature = <20000>; hysteresis = <2000>; };
          };
          fragment@2 {
            target-path = "/thermal-zones/cpu-thermal/trips/trip1";
            __overlay__ { temperature = <25000>; hysteresis = <2000>; };
          };
          fragment@3 {
            target-path = "/thermal-zones/cpu-thermal/trips/trip2";
            __overlay__ { temperature = <40000>; hysteresis = <2000>; };
          };
          fragment@4 {
            target-path = "/thermal-zones/cpu-thermal/trips/trip3";
            __overlay__ { temperature = <60000>; hysteresis = <5000>; };
          };
        };
      '';
    }
  ];


  # Tweak UDP send/recv buffer size 
  # To resolve Unbound memory warnings
  boot.kernel.sysctl."net.core.wmem_max" = 16777216;
  boot.kernel.sysctl."net.core.rmem_max" = 16777216;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vilnius";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # networking config. important for ssh!
  networking = {
    hostName = "matrix";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "192.168.1.3";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.1.1"; # or whichever IP your router is
      interface = "eth0";
    };
    nameservers = [ "192.168.1.2" ]; # not using DHCP, so we need to specify nameservers manually
  };

  # Define the default shell assigned to user accounts.
  users.defaultUserShell = pkgs.zsh;

  # the user account on the machine
  users.users.neo = {
    isNormalUser = true;
    initialHashedPassword = "";
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa2OjDgz4VVeOLQTNjpXrLsYIX8XtJOKicgfvhOXpeCoZlMQl0mTCU80rrgLZCckoDMCGB2GRrajs3mwYvX6HSAJgXKIUpGFqVcNHigI6eNXv5dXhJ4Tw1fJl6xgInLqt6IpzYnONKiMM2ZZvNErTa/NuI5upRlpROPyn3EWbVUVTQ/cfppz7aCijoVCrkmNldpepXu8rYlyTnCWF8xZNDyL+ZYAxq2Kap5J9oIgJbqIXZqjtO0pp5oJQC64ExA8QVakC4UH9x9uzDSnvInIG8Ri3v2Jg5IFBCdGBpnK3YUU7YVVkIJ9QBLjDHyqWgrr/0p5lF+Iid6+jfY/OSieTP"
    ];
  };

  # A list of permissible login shells for user accounts.
  # /bin/sh is placed into this list implicitly.
  environment.shells = with pkgs; [ zsh ];

  # I use neovim as my text editor, replace with whatever you like
  environment.systemPackages = with pkgs; [
    (import ../scripts/initialize.nix { inherit pkgs; })
    (import ../scripts/switch-home.nix { inherit pkgs; })
    (import ../scripts/switch-host.nix { inherit pkgs; })

    neovim
    wget
    git

    ## Network tools
    net-tools
    dig

    ## Raspberry Pi tools
    libraspberrypi
    raspberrypi-eeprom
  ];

  # Z Shell must be enabled system-wide.
  # Otherwise it won't source the necessary files.
  programs.zsh = {
    enable = true;
  };

  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  sops.defaultSopsFile = ./secrets/secrets.yaml;

  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;

  # This is the actual specification of the secrets.

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ]; # Default SSH port
    settings = {
      PasswordAuthentication = false; # Disable password authentication
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
