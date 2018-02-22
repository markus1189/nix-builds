{ pkgs ? import <nixpkgs> {}}: with pkgs;

let
  libPath = stdenv.lib.makeLibraryPath (with pkgs.xorg; [
    alsaLib
    atk
    cairo
    cups
    dbus_daemon.lib
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
  runtimeLibs = stdenv.lib.makeLibraryPath [ libudev0-shim glibc curl ];
in stdenv.mkDerivation rec {
  name = "insomnia-${version}";
  version = "5.14.7";
  src = fetchurl {
    url = "https://github.com/getinsomnia/insomnia/releases/download/v${version}/insomnia_${version}_amd64.deb";
    sha256 = "1y6bn9kaxxplzyv7jjrcsfkrjnivjqdk5mbdp8vz32hv2bmdvzzy";
  };

  nativeBuildInputs = [ dpkg ];

  buildInputs = [ makeWrapper ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/lib

    mv opt/Insomnia/* $out/
    mv $out/*.so $out/lib/
  '';

  preFixup = ''
    for lib in $out/lib/*.so; do
      patchelf --set-rpath "$out/lib:${libPath}" $lib
    done

    for bin in $out/insomnia; do
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
               --set-rpath "$out/lib:${libPath}" \
               $bin
    done

    wrapProgram "$out/insomnia" --prefix LD_LIBRARY_PATH : ${runtimeLibs}
  '';
}
