{ pkgs ? import <nixpkgs> { system = "i686-linux";}
, savesDir
}: with pkgs;

assert lib.pathExists savesDir;

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
    alsaLib
    libpulseaudio
  ];

  phases = [ "unpackPhase" "installPhase" ];

  ldPath = stdenv.lib.makeLibraryPath buildInputs;

  src = ./Desktop_Dungeons_EE_Linux_1_57.tar.gz;

  installPhase = ''
    mkdir -p $out

    patchelf --set-rpath "${ldPath}" DesktopDungeons_Data/Plugins/x86/ScreenSelector.so
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
             --set-rpath "$out/DesktopDungeons_Data/Plugins/x86:${ldPath}" \
             DesktopDungeons.x86

    rm Install.sh DesktopDungeons.sh

    mv * $out/

    echo "Linking ${savesDir} to hold savegame files"
    ln -s ${savesDir} $out/DesktopDungeons_Data/Saves
  '';
}
