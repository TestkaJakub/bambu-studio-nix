{
  lib,
  appimageTools,
  fetchurl,
  makeDesktopItem,
  cacert,
  glib-networking,
  glibcLocales,
}:

# Bambu Studio: wraps the official ubuntu24.04 AppImage and provides
#   $out/bin/bambu-studio                        ready-to-run command (FHS env)
#   $out/share/applications/bambu-studio.desktop launcher entry
#   $out/share/pixmaps/bambu-studio.png          icon taken from the AppImage
#
# Why not nixpkgs' bambu-studio: it's built from source and marked unfree, so
# Hydra never caches it and every update means a long local compile. The
# AppImage is already compiled upstream; wrapping it takes seconds.
let
  pname   = "bambu-studio";
  version = "02.08.02.61";
  build   = "20260820225108";   # timestamp from the asset file name

  src = fetchurl {
    url    = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubuntu24.04-v${version}-${build}.AppImage";
    sha256 = "d501b103fac5424513ec0e8d6bc145fb30719de2c7d94d7320d723740c81a7fd";
  };

  # Same derivation wrapType2 uses internally, so no extra unpacking
  contents = appimageTools.extract { inherit pname version src; };

  desktopItem = makeDesktopItem {
    name        = pname;
    desktopName = "Bambu Studio";
    comment     = "3D printing slicer for Bambu Lab printers";
    exec        = "bambu-studio %F";
    icon        = pname;
    categories  = [ "Graphics" "3DGraphics" "Engineering" ];
    mimeTypes   = [ "model/stl" "model/3mf" "application/vnd.ms-3mfdocument" ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # TLS, GIO networking and locales for the login / cloud features
  profile = ''
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules/"
    export LANGUAGE=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LOCALE_ARCHIVE="${glibcLocales}/lib/locale/locale-archive"
  '';

  extraPkgs = p: with p; [
    cacert glib glib-networking glibcLocales curl
    webkitgtk_4_1
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  extraInstallCommands = ''
    install -Dm444 ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    icon=$(find ${contents} -maxdepth 1 -name '*.png' | head -n1)
    [ -n "$icon" ] && install -Dm444 "$icon" $out/share/pixmaps/${pname}.png
  '';

  meta = {
    description = "Bambu Studio, the Bambu Lab slicer, from the official AppImage";
    homepage    = "https://github.com/bambulab/BambuStudio";
    license     = lib.licenses.agpl3Plus;
    platforms   = [ "x86_64-linux" ];
    mainProgram = "bambu-studio";
  };
}