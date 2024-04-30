# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git";
      rev = "e1c4bac14beb8c409d0534382cf967171706b9d9"; }}/apple/t2"

      # Services
      ./swaywm.nix
      ../../services/pipewire.nix

      # Programs
      ../../programs/vim.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
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

  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "brcm-firmware";

      buildCommand = ''
        dir="$out/lib/firmware"
        mkdir -p "$dir"
        cp -r ${./firmware}/* "$dir"
      '';
    })
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "darwin"; 
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

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
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.videoDrivers = [ "amdgpu" ];
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true; 

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Install docker
  virtualisation.docker.enable = true;

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
    git
    wget
    htop

    # NetworkManager control applet
    networkmanagerapplet

    # This program allows you read and control device brightness on Linux.
    brightnessctl

    # Generic graphical webcam configuration tool
    # TODO: move to pkgs, install as a user, not system wide?
    (callPackage ../../programs/cameractrls.nix { })
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the blueman service, which provides blueman-applet and blueman-manager.
  services.blueman.enable = true;

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

  # Specifies what to do when the laptop lid is closed and the system is on external power.
  # By default use the same action as specified in services.logind.lidSwitch.
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

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
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

