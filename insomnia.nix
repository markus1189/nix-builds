{ pkgs ? import <nixpkgs> {}}: with pkgs;

stdenv.mkDerivation rec {
  name = "insomnia-${version}";
  version = "5.14.7";
  src = fetchurl {
    url = "https://github.com/getinsomnia/insomnia/releases/download/v${version}/insomnia_${version}_amd64.deb";
    sha256 = "1y6bn9kaxxplzyv7jjrcsfkrjnivjqdk5mbdp8vz32hv2bmdvzzy";
  };

  buildInputs = [ dpkg ];

  unpackPhase = "dpkg-deb -x $src .";

  ldPath = stdenv.lib.makeLibraryPath (with pkgs.xorg; [
    alsaLib
    atk
    cairo
    cups
    dbus_daemon.lib
    dpkg
    expat
    fontconfig
    freetype
    gdk_pixbuf
    glib
    gnome2.GConf
    gnome2.pango
    gtk2-x11
    nspr
    nss
    stdenv.cc.cc.lib
    udev.lib

    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxcb
  ]);

  installPhase = ''
    mkdir -p $out

    mv opt/Insomnia/* $out/

    for lib in libnode.so libffmpeg.so; do
      patchelf --set-rpath "$out:$out:${ldPath}" $out/$lib
    done

    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
             --set-rpath "$out:$out:${ldPath}" \
             $out/insomnia
  '';
}
