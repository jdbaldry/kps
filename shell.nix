{ pkgs ? import <nixpkgs> }:

with pkgs;
mkShell {
  buildInputs = [
    go_1_19
    gopls
    gotools
  ];
  shellHook = ''
    # ...
  '';
}
