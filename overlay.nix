final: prev:

with prev; {
  xinput_exporter = callPackage ./default.nix { pkgs = prev; };
}
