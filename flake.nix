{
  description = "xinput_exporter shell development tooling";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay = final: prev: {
        xinput_exporter = prev.callPackage ./default.nix { pkgs = prev.pkgs; };
      };
      nixosModules = rec {
        default = xinput_exporter;
        xinput_exporter = { config, lib, pkgs, ... }:
          with lib;
          let
            cfg = config.services.xinput_exporter;
            drv = pkgs.callPackage ./default.nix { inherit pkgs; };
          in
          {
            options.services.xinput_exporter = {
              enable = mkEnableOption "xinput_exporter";
              display = mkOption {
                description = "The value for the DISPLAY environment variable.";
                default = ":0";
                type = types.str;
              };

              listen-address = mkOption {
                description = "The address to listen on for HTTP requests.";
                default = ":9191";
                type = types.str;
              };

              user = mkOption {
                description = "The user to use for their .Xauthority cookie.";
                type = types.str;
              };
            };

            config = mkIf cfg.enable {
              systemd.services.xinput_exporter = {
                description = "Exporter of xevents using xinput";

                serviceConfig = {
                  Environment = [ "DISPLAY=${cfg.display}" ];
                  ExecStart = "${drv}/bin/xinput_exporter -listen-adress=${cfg.listen-address}";
                  Restart = "always";
                  User = cfg.user;
                };

                wantedBy = [ "graphical.target" ];
              };
            };
          };
      } //
      (flake-utils.lib.eachSystem [ "x86_64-linux" ]
        (system:
          let pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
          in {
            defaultPackage = pkgs.xinput_exporter;
            devShell = import ./shell.nix { inherit pkgs; };
          }));
    };
}
