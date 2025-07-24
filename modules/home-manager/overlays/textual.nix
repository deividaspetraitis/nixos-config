{ pinnedTextual }:
final: prev: rec {
  python3Packages =
    prev.python3Packages
    // {
      textual =
        pinnedTextual.legacyPackages.${prev.system}.python3Packages.textual;
    };
}
