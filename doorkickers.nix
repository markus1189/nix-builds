# Nix file for DoorKickers
#
# - make sure 'DoorKickers.tar.gz' is in the same dir
# - run:
# $ nix-build -E 'with import <nixpkgs> { }; callPackage_i686 ./default.nix { }'
{stdenv, openal, glibc, libX11, libogg, xorg, makeWrapper }:
stdenv.mkDerivation {
  name = "DoorKickers";
  src = ./DoorKickers.tar.gz;

  buildInputs = [ makeWrapper ];

  libPath = stdenv.lib.makeLibraryPath [
    glibc
    libX11
    libogg
    openal
    stdenv.cc.cc
    xorg.libXxf86vm
  ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p "$out/opt"
    cp -r data "$out/opt/"
    cp -r mods "$out/opt/"
    cp -r DoorKickers "$out/opt/"
    cp -r linux_libs "$out/lib"
    cp -r linux_libs "$out/opt/"
    chmod +x "$out/opt/DoorKickers"

    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
             --set-rpath "$libPath:$out/lib" \
             "$out/opt/DoorKickers"

    for i in $out/lib/lib*; do
      patchelf --set-rpath "$libPath:$out/lib" "$i"
    done

    mkdir "$out/bin"

    wrapProgram "$out/opt/DoorKickers" --run "cd $out/opt/"
    ln -s "$out/opt/DoorKickers" "$out/bin/DoorKickers"
  '';
}
