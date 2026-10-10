# NixOS module: programs.bambu-studio
self:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.bambu-studio;

  inherit (lib) mkOption mkEnableOption mkIf types;

  configured =
    if !cfg.forceX11 then cfg.package
    else pkgs.symlinkJoin {
      name              = "bambu-studio-x11";
      paths             = [ cfg.package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/bambu-studio --set-default GDK_BACKEND x11
      '';
      inherit (cfg.package) meta;
    };
in
{
  options.programs.bambu-studio = {
    enable = mkEnableOption "Bambu Studio, the Bambu Lab slicer (official AppImage)";

    package = mkOption {
      type        = types.package;
      default     = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "bambu-studio-nix.packages.\${system}.default";
      description = "The Bambu Studio package to use.";
    };

    forceX11 = mkOption {
      type        = types.bool;
      default     = false;
      description = ''
        Run through XWayland (GDK_BACKEND=x11). Helps with 3D view glitches on
        some Wayland compositors. Can still be overridden per run.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ configured ];
  };
}