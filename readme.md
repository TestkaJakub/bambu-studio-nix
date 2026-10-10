# bambu-studio-nix

A simple Nix flake that packages the official [Bambu Studio](https://github.com/bambulab/BambuStudio) AppImage as a ready-to-run `bambu-studio` command.

## Why not nixpkgs?

nixpkgs builds Bambu Studio from source and marks it unfree, so it's never in
the binary cache and every update means a long local compile. This flake wraps
the AppImage Bambu already compiled, which takes seconds.

## Installation

### Nix (flakes)

Run without installing:

```
nix run github:TestkaJakub/bambu-studio-nix
```

On NixOS, add it as a flake input and enable the module:

```
# flake.nix
inputs.bambu-studio.url = "github:TestkaJakub/bambu-studio-nix";

# configuration.nix
imports = [ inputs.bambu-studio.nixosModules.default ];
programs.bambu-studio.enable = true;
```

Or just the package:

```
environment.systemPackages = [
  inputs.bambu-studio.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

## Updating

On the [latest release](https://github.com/bambulab/BambuStudio/releases/latest)
page, under Assets, take from the `ubuntu24.04` AppImage:

- `version` from the tag (`v02.08.02.61` → `02.08.02.61`),
- `build`, the timestamp in the file name,
- `sha256`, shown next to the file,

and put them in `package.nix`.

## License

This repository only contains Nix packaging. Bambu Studio is downloaded from
its GitHub releases at build time and remains under its authors' terms.