{ config, lib, pkgs, ... }:
# https://nixos.wiki/wiki/Sway
{
  environment.systemPackages = with pkgs; [
    wayland
	waybar # Highly customizable Wayland bar for Sway and Wlroots based compositors
    wev  # wayland event viewer
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    glibc
    dracula-theme # gtk theme
    adwaita-icon-theme # default gnome cursors
    swaylock
    swayidle
    grim # screenshot functionality
    slurp # screenshot a region of the screen
    swappy # native snapshot and editor tool
    swaynotificationcenter # notification center for sway
    rofi # Rofi is a window switcher, application launcher and dmenu replacement
    wf-recorder # screen recorder for wlroots-based compositors
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wdisplays # tool to configure displays
    wlr-randr
  ];

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

  environment = {
    etc = {
      "sway/config".source = ../../.dotfiles/sway/config;
      "sway/conf.d".source = ../../.dotfiles/sway/config.d;
      "sway/swaync".source = ../../.dotfiles/swaync/config.json;
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
}

