{ lib, stdenv }: 

stdenv.mkDerivation {
  name = "arnix-installer";

  src = ./.;

  dontBuild = true;
  dontPatchShebangs = true;
  installPhase = ''
    mkdir -p $out
    install -m 777 hijack.sh $out/hijack-script
    install -m 777 install.sh $out/install-arnix
  '';
}