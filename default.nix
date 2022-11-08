{ pkgs ? import <nixpkgs> }:

with pkgs;
buildGoModule rec {
  pname = "xinput_exporter";

  src = lib.cleanSource ./.;
  version = "0.1.0";
  vendorSha256 = "sha256-hyn8oAs2GaH2p6awQ3mYMDYhaxsx8cKn9SmCbKpm6FM=";

  nativeBuildInputs = [ pkgs.makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/xinput_exporter --set PATH "${pkgs.xorg.xinput}/bin"
  '';


  meta = with lib; {
    description = "Expose xevents from xinput as Prometheus metrics.";
    homepage = "https://github.com/jdbaldry/xinput_exporter";
    license = licenses.gpl3;
    maintainers = with maintainers; [ jdbaldry ];
    platforms = platforms.linux;
  };
}
