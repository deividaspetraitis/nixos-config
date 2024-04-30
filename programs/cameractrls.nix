{ lib, python3Packages, SDL2, libjpeg, gobject-introspection, fetchFromGitHub, wrapGAppsHook, glib, gtk4 }:
python3Packages.buildPythonApplication rec {
  pname = "cameractrls";
  version = "v0.6.3";

  src = fetchFromGitHub {
    owner = "soyersoyer";
    repo = pname;
    rev = version;
    sha256 = "sha256-bFUfMJOYqNUw7+Bvj+iAEmfCJfq4Gr7TA84N2IneUT8=";
  };

  format = "other";

  dontBuild = true;

  buildInputs = [
    SDL2
    libjpeg
    gtk4
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp cameractrls.py $out/share
    cp cameractrlsgtk4.py $out/bin/cameractrls-gtk
  '';

  makeWrapperArgs = [
    "--prefix PYTHONPATH : ${placeholder "out"}/share"
  ];
}
