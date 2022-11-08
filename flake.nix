{
  description = "xinput_exporter shell development tooling";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay = import ./overlay.nix;
    } //
    (flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
      in {
        devShell = import ./shell.nix { inherit pkgs; };
        defaultPackage = pkgs.xinput_exporter;
      }));
}
