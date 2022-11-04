{ lib, stdenv }: 

stdenv.mkDerivation {
  name = "arnix-installer";

  src = ./.;

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    install -m 777 install.sh $out/bin/install-arnix
  '';
}