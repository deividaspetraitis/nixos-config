# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

{
  # Turn on periodic optimisation of the nix store.
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ]; # optimisation schedule

  # Automate garbage collection.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Services
      ./swaywm.nix
      ../../services/pipewire.nix

      # Programs
      ../../programs/vim.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ 
    # I²C or I2C (Inter-IC) is a synchronous, multi-controller/multi-target (controller/target), 
    # packet switched, single-ended, serial communication bus invented in 1982 by Philips Semiconductors.
    #
    # It is used by many hardware boards to communicate with general purpose I/O (GPIO) devices.
    "i2c-dev" 

    # A pair of Linux kernel drivers for DDC/CI monitors.
    # DDC/CI is a control protocol for monitor settings supported by most monitors since about 2005
    "ddcci_backlight"

    # udl — DisplayLink DL-120 / DL-160 USB display devices
    "udl"
  ];

  # The set of kernel modules to be loaded in the second stage of the boot process.
  # Note that modules that are needed to mount the root file system should be added to boot.initrd.availableKernelModules or boot.initrd.kernelModules.
  # boot.kernelModules = [ ];

  networking.hostName = "helix"; # Define your hostname.
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
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable i2c devices support.
  # By default access is granted to users in the “i2c” group (will be created if non-existent) and any user with a seat, meaning logged on the computer locally.
  hardware.i2c.enable = true;

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
    nerd-fonts.jetbrains-mono
    nerd-fonts.space-mono
    nerd-fonts.dejavu-sans-mono
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    htop
    wget

    # This program allows you read and control device brightness on Linux.
    brightnessctl
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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

  # List of packages containing udev rules. 
  services.udev.packages = with pkgs; [
    qmk-udev-rules
  ];

  # Enable thermald, the temperature management daemon.
  services.thermald.enable = true;

  # Enable the blueman service, which provides blueman-applet and blueman-manager.
  services.blueman.enable = true;

  # Enable power management. 
  # This includes support for suspend-to-RAM and powersave features on laptops.
  powerManagement.enable = true;

  # Power management settings.
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    IdleAction=suspend
    IdleActionSec=30min
  '';
  
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
