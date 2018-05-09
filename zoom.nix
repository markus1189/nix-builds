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
    libpulseaudio
    libGL
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
    mkdir -p $out/share/zoom $out/bin
    mv * $out/share/zoom/
  '';

  preFixup = ''
    for lib in $(find $out/share/zoom -name "*.so.*" -not -type l) platforms/*; do
      patchelf --set-rpath "$out/share/zoom:$out/share/zoom/platforms:${ldPath}" $lib
    done

    for lib in $out/share/zoom/platforms/*; do
      patchelf --set-rpath "$out/share/zoom:$out/share/zoom/platforms:${ldPath}" $lib
    done

    for bin in $(find $out/share/zoom -executable -not '(' -name "*.so*" -or -name "*.pcm" -or -name "*.sh" -or -name "zoomlinux" ')' -type f); do
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
               --set-rpath "$out/share/zoom:$out/share/zoom/platforms:${ldPath}" \
               $bin
    done

    rm $out/share/zoom/zoom.sh

    ln -s $out/share/zoom/zoom $out/bin/zoom

    for bin in $out/bin/*; do
      wrapProgram $bin \
        --set QT_XKB_CONFIG_ROOT "${xorg.xkeyboardconfig}/share/X11/xkb"
    done
  '';

    meta = with stdenv.lib; {
    homepage = https://zoom.us/;
    description = "Video Conferencing and Web Conferencing Service";
    license = stdenv.lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ markus1189 ];
  };
}
