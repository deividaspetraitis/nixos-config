# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Services
      ./swaywm.nix

      ./hyprland.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Resume from file, if left empty, the swap partitions are used
  boot.resumeDevice = "/dev/nvme0n1p3";

  # Resume offset can be found with the following command:
  # sudo filefrag -v /var/swap
  boot.kernelParams = [
    "resume=/var/swap"
    "resume_offset=61270016"
  ];

  networking.hostName = "am4"; # Define your hostname.

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Vilnius";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable polkit
  security.polkit.enable = true;

  # Enable rtkit
  security.rtkit.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Install docker
  virtualisation.docker.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware.amdgpu.amdvlk.enable = true;
  hardware.amdgpu.initrd.enable = true;

  # Whether to enable all firmware regardless of license.
  hardware.enableAllFirmware = true;

  # Whether to enable firmware with a license allowing redistribution.
  hardware.enableRedistributableFirmware = true;

  # Enable i2c devices support.
  # By default access is granted to users in the “i2c” group (will be created if non-existent) and any user with a seat, meaning logged on the computer locally.
  hardware.i2c.enable = true;

  # Enable udev rules for Ledger devices.
  hardware.ledger.enable = true;

  # Enables support for Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings = {
    # Modern headsets will generally try to connect using the A2DP profile. 
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = "true";
    };
    Policy = {
      AutoEnable = "true";
    };
  };

  # Whether to enable OpenGL drivers. 
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Enable pass secret service
  services.passSecretService.enable = true;

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # Enable OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins; # enable all plugins
  };

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable the 1Password secrets service.
  services.onepassword-secrets = {
    enable = true;
    users = [ "deividas" ]; # Users that need secret access
    tokenFile = "/etc/opnix-token"; # Default location
    configFile = pkgs.writeText "opnix-config.json" (builtins.toJSON {
      secrets = [ ]; # no system secrets
    });
    outputDir = "/var/lib/opnix/secrets"; # Optional, this is the default
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define the default shell assigned to user accounts.
  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.deividas = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "networkmanager"
      "wireshark"
      "docker" # Provide them access to the socket
      "i2c"
      "onepassword-secrets"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa2OjDgz4VVeOLQTNjpXrLsYIX8XtJOKicgfvhOXpeCoZlMQl0mTCU80rrgLZCckoDMCGB2GRrajs3mwYvX6HSAJgXKIUpGFqVcNHigI6eNXv5dXhJ4Tw1fJl6xgInLqt6IpzYnONKiMM2ZZvNErTa/NuI5upRlpROPyn3EWbVUVTQ/cfppz7aCijoVCrkmNldpepXu8rYlyTnCWF8xZNDyL+ZYAxq2Kap5J9oIgJbqIXZqjtO0pp5oJQC64ExA8QVakC4UH9x9uzDSnvInIG8Ri3v2Jg5IFBCdGBpnK3YUU7YVVkIJ9QBLjDHyqWgrr/0p5lF+Iid6+jfY/OSieTP"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # A list of permissible login shells for user accounts.
  # /bin/sh is placed into this list implicitly.
  environment.shells = with pkgs; [ zsh ];

  # Installing fonts on NixOS.
  # Be aware that sometimes font names and packages name differ and there is no universal convention in NixOS.
  fonts.packages = with pkgs; [
    nerd-fonts.space-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.dejavu-sans-mono
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bluez-alsa
    bluez-tools

    pavucontrol # PulseAudio Volume Control

    i2c-tools
    time
    git
    wget
    htop
    nvtopPackages.full

    # This program allows you read and control device brightness on Linux.
    brightnessctl

    # Tool for reading and parsing EDID data from monitors
    read-edid
    edid-decode

    # FUSE-based filesystem that allows remote filesystems to be mounted over SSH
    sshfs

    # Collection of common network programs
    inetutils

    # AMD
    stable.rocmPackages.clr

    # Generic graphical webcam configuration tool
    # TODO: move to pkgs, install as a user, not system wide?
    (callPackage ../../programs/cameractrls.nix { })

    protonup-qt

    ncdu
    i2c-tools
    inxi
    pciutils
    lact
    virtualgl
  ];

  # Whether to enable nix-ld, documentation: https://github.com/Mic92/nix-ld.
  programs.nix-ld.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # Enable nm-applet, a NetworkManager control applet for GNOME.
  programs.nm-applet.enable = true;

  # SSH client configuration
  programs.ssh = {
    extraConfig = ''
      Host *
          IdentityAgent ~/.1password/agent.sock
    '';
  };

  # Add Wireshark to the global environment and configure a setcap wrapper for ‘dumpcap’ for users in the ‘wireshark’ group.
  # Set package to GUI application instead of default wireshark-cli.
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Enable 1password module instead of using user level package.
  # 1password CLI requires special permissions in order to function properly: https://github.com/NixOS/nixpkgs/issues/258139
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "deividas" ];
  programs._1password.enable = true;

  # Z Shell must be enabled system-wide.
  # Otherwise it won't source the necessary files.
  programs.zsh = {
    enable = true;
  };

  # List services that you want to enable:
  programs.dconf.enable = true;

  # Enable Steam
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    package = with pkgs; steam.override { extraPkgs = pkgs: [ attr ]; };
  };

  # List services that you want to enable:

  # Enable flatpak
  services.flatpak.enable = true;

  # Enable thermald, the temperature management daemon.
  services.thermald.enable = true;

  # Enable the blueman service, which provides blueman-applet and blueman-manager.
  services.blueman.enable = true;

  # udev rules
  services.udev = {
    extraRules = ''
      SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
    '';
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
      51820 # Clients and peers can use the same port, see listenport
    ];

    # If you intend to route all your traffic through the wireguard tunnel, the default configuration 
    # of the NixOS firewall will block the traffic because of rpfilter.
    checkReversePath = "loose";

    extraCommands = ''
              iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
              iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
      	'';
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
  system.stateVersion = "24.05"; # Did you read the comment?
}

