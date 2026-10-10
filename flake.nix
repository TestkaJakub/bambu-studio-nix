{
  description = "Bambu Studio — official AppImage, ready to run on Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        bambu-studio = pkgs.callPackage ./package.nix { };
        default      = bambu-studio;
      });

      overlays.default = final: _prev: {
        bambu-studio-appimage = final.callPackage ./package.nix { };
      };

      nixosModules = rec {
        bambu-studio = import ./module.nix self;
        default      = bambu-studio;
      };

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}