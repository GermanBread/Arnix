{ lib, stdenv, fakeroot }: 

stdenv.mkDerivation {
  name = "arnix-tarball";

  src = ./.;

  nativeBuildInputs = [ fakeroot ];

  dontBuild = true;
  installPhase = ''
    mkdir -p $out

    chmod 755 -R bin
    fakeroot tar c bin etc update >$out/arnix-bootstrap.tar
    gzip -f $out/arnix-bootstrap.tar
    cd $out
    sha1sum arnix-bootstrap.tar.gz >arnix-bootstrap.sha1sum
  '';
}