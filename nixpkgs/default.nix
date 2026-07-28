final: prev: {
  raiseorrun = final.callPackage ../hosts/scripts/raise-or-run.nix { };
  mprisvolume = final.callPackage ../.dotfiles/waybar/scripts/mpris-volume.nix { };
  mprisscroll = final.callPackage ../.dotfiles/waybar/scripts/mpris-scroll.nix { };
  mprisposition = final.callPackage ../.dotfiles/waybar/scripts/mpris-position.nix { };
  zscroll = final.callPackage ./zscroll/default.nix { };
}
