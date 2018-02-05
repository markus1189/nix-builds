{ pkgs ? import <nixpkgs> { system = "i686-linux";}
}: with pkgs;

stdenv.mkDerivation rec {
  name = "desktop-dungeons";
  version = "1.57";

  buildInputs = [
    mesa_glu
    binutils
    xorg.libX11
    xorg.libXcursor
    stdenv.cc.cc
    glib
    gdk_pixbuf
    gtk2
  ];

  ldPath = stdenv.lib.makeLibraryPath buildInputs;

  src = ./Desktop_Dungeons_EE_Linux_1_57.tar.gz;

  installPhase = ''
    mkdir -p $out

    patchelf --set-rpath "${ldPath}" DesktopDungeons_Data/Plugins/x86/ScreenSelector.so
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
             --set-rpath "$out/DesktopDungeons_Data/Plugins/x86:${ldPath}" \
             DesktopDungeons.x86

    mv * $out/

    # TODO find a better way, according to support there is no configuration possible
    ln -s /tmp/DDSaves $out/DesktopDungeons_Data/Saves
  '';
}
