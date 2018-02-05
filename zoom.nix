{ pkgs ? import <nixpkgs> {} }: with pkgs;

stdenv.mkDerivation rec {
  name = "zoom-${version}";
  version = "2.0.115900.1201";

  src = fetchurl {
    url = "https://zoom.us/client/${version}/zoom_x86_64.tar.xz";
    sha256 = "1ssd1mdmbxdf5b2drv23ag8hznlj29b1qaldsn3gpn94mzvh6nrl";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    zlib
    glib
    glibc
    stdenv.cc.cc
    nss
    freetype
    fontconfig
    dbus
    mesa_noglu
    alsaLib
    expat
    sqlite
    utillinux
    nspr
  ] ++ (with xorg; [
    libXdamage
    libX11
    libxcb
    libXrandr
    libXcursor
    libXScrnSaver
    libXi
    libXext
    libXrender
    libSM
    libICE
    libXtst
    libXcomposite
    libXfixes
    xcbutilimage
    xcbutilkeysyms
    xkeyboardconfig
  ]);

  ldPath = stdenv.lib.makeLibraryPath buildInputs;

  installPhase = ''
    mkdir -p $out
    mv * $out/

    for lib in $(find $out -name "*.so.*" -not -type l) platforms/*; do
      patchelf --set-rpath "$out:$out/platforms:${ldPath}" $lib
    done

    for lib in $out/platforms/*; do
      patchelf --set-rpath "$out:$out/platforms:${ldPath}" $lib
    done

    for bin in $(find $out -executable -not '(' -name "*.so*" -or -name "*.pcm" -or -name "*.sh" -or -name "zoomlinux" ')' -type f); do
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
               --set-rpath "$out:$out/platforms:${ldPath}" \
               $bin
    done

    rm $out/zoom.sh

    for bin in $out/zoom $out/zopen; do
      wrapProgram $bin --set QT_XKB_CONFIG_ROOT "${xorg.xkeyboardconfig}/share/X11/xkb"
    done
  '';
}
