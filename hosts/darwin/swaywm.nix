{config, lib, pkgs, ...}:

# https://nixos.wiki/wiki/Sway
let
  # bash script to let dbus know about important env variables and
  # propogate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  systemctl --user stop pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
      name = "configure-gtk";
      destination = "/bin/configure-gtk";
      executable = true;
      text = let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Dracula'
        '';
  };

in
{
  environment.systemPackages = with pkgs; [
    dbus-sway-environment
    configure-gtk
    wayland
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    glibc
    libva-utils
    glxinfo
    dracula-theme # gtk theme
    adwaita-icon-theme  # default gnome cursors
    swaylock
    swayidle
    swayidle
    grim # screenshot functionality
    mako # notification system developed by swaywm maintainer
    waybar
    wf-recorder
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wofi
    wdisplays # tool to configure displays
    wlr-randr
  ];

  services.pipewire.wireplumber.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures = {
      gtk = true;
    };
  };

  services.displayManager.defaultSession = "sway";
  services.displayManager.sddm.wayland.enable = true;

  # Enable SSDM
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.settings = {
    General = {
      InputMethod = "";
    };
  };

  services.desktopManager.plasma6.enable = true;

  environment = {
    etc = {
      "sway/config".source = ../../.dotfiles/sway/config;
      "sway/conf.d".source = ../../.dotfiles/sway/config.d;

      "xdg/waybar/config".source = ../../.dotfiles/waybar/config;
      "xdg/waybar/style.css".source = ../../.dotfiles/waybar/style.css;
    };
  };

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  programs.waybar.enable = true;
  programs.xwayland.enable = true;
}

