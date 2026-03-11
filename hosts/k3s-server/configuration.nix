# configuration.nix

{ pkgs, config, lib, ... }:

{
  imports = [
    # Include common configuration
    ../../modules/configuration.nix

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
            __overlay__ { temperature = <65000>; hysteresis = <2000>; };
          };
          fragment@4 {
            target-path = "/thermal-zones/cpu-thermal/trips/trip3";
            __overlay__ { temperature = <70000>; hysteresis = <5000>; };
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

  host = {
    hostName = "k3s-server";
    interface = "eth0";
    ipv4Address = "192.168.1.5";
    gateway = "192.168.1.1";
    nameservers = [ "192.168.1.2" ];
    username = "ops";
    sshKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa2OjDgz4VVeOLQTNjpXrLsYIX8XtJOKicgfvhOXpeCoZlMQl0mTCU80rrgLZCckoDMCGB2GRrajs3mwYvX6HSAJgXKIUpGFqVcNHigI6eNXv5dXhJ4Tw1fJl6xgInLqt6IpzYnONKiMM2ZZvNErTa/NuI5upRlpROPyn3EWbVUVTQ/cfppz7aCijoVCrkmNldpepXu8rYlyTnCWF8xZNDyL+ZYAxq2Kap5J9oIgJbqIXZqjtO0pp5oJQC64ExA8QVakC4UH9x9uzDSnvInIG8Ri3v2Jg5IFBCdGBpnK3YUU7YVVkIJ9QBLjDHyqWgrr/0p5lF+Iid6+jfY/OSieTP"
    ];
    sopsFile = ./secrets/secrets.yaml;
  };



  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    ## Raspberry Pi tools
    libraspberrypi
    raspberrypi-eeprom
  ];

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
