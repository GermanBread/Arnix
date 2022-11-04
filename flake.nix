{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: rec {

    packages.x86_64-linux.arnix-bootstrap = nixpkgs.legacyPackages.x86_64-linux.callPackage ./src/image/default.nix { };
    packages.x86_64-linux.arnix-installer = nixpkgs.legacyPackages.x86_64-linux.callPackage ./src/installer/default.nix { };

    packages.x86_64-linux.default = self.packages.x86_64-linux.arnix-installer;
  };
}
