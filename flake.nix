{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: rec {
    packages.x86_64-linux.image = nixpkgs.legacyPackages.x86_64-linux.callPackage ./src/image/default.nix { };
    packages.x86_64-linux.installer = nixpkgs.legacyPackages.x86_64-linux.callPackage ./src/installer/default.nix { };
  };
}
