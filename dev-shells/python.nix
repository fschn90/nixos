{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    zlib
    python3
    python311Packages.pip
    python311Packages.virtualenv
    python311Packages.spacy
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.zlib}/lib"
  '';
}
