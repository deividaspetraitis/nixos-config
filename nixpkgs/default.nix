{ nixpkgs }:
let
  allPkgs = nixpkgs // pkgs;
  pkgs = with nixpkgs; {
    # myvim = import ./vim/default.nix { pkgs = pkgs; };
  };
in
  pkgs
