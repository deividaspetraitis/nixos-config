# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Services
      ../services/swaywm.nix
      ../services/pipewire.nix

      # Programs
      ../programs/vim.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "udl" ];

  # The set of kernel modules to be loaded in the second stage of the boot process.
  # Note that modules that are needed to mount the root file system should be added to boot.initrd.availableKernelModules or boot.initrd.kernelModules.
  # boot.kernelModules = [ ];

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Vilnius";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable polkit
  security.polkit.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Install docker
  virtualisation.docker.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enables support for Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings = { # modern headsets will generally try to connect using the A2DP prof
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      intel-ocl
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Define the default shell assigned to user accounts.
  users.defaultUserShell = pkgs.zsh;

  # A list of permissible login shells for user accounts.
  # /bin/sh is placed into this list implicitly.
  environment.shells = with pkgs; [ zsh ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.deividas = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" # Enable ‘sudo’ for the user.
      "networkmanager" 
      "docker" # Provide them access to the socket
    ]; 
    packages = with pkgs; [
      tree
    ];
  };

  # Installing fonts on NixOS.
  # Be aware that sometimes font names and packages name differ and there is no universal convention in NixOS.
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    htop
    wget

    # QMK is powering my keyboard I tune from time to time.
    qmk
    # used by vim
    # ripgrep
    # (pkgs.callPackage ../programs/vim.nix {})

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Z Shell must be enabled system-wide.
  # Otherwise it won't source the necessary files.
  programs.zsh = {
    enable = true;
  };

  # List services that you want to enable:

  # List of packages containing udev rules. 
  services.udev.packages = with pkgs; [
    qmk-udev-rules
  ];

  # Enable the blueman service, which provides blueman-applet and blueman-manager.
  services.blueman.enable = true;
  
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
