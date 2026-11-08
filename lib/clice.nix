{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  glibc,
}:

stdenvNoCC.mkDerivation rec {
  pname = "clice";
  version = "0.1.2026110716";

  # Upstream release source: ec5b90e1617bda438e794aa1ac3a84da21b00be5.
  src = fetchurl {
    url = "https://github.com/clice-io/clice/releases/download/v${version}/clice-${version}.x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-BbncGIUNyFA9NwaDGgDiOmiIumD/WP/I1g52gTOe+uQ=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ glibc ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    # Resource lookup is relative to bin/clice; workers re-exec the same ELF.
    cp -r bin lib clice.toml "$out/"
    install -Dm644 LICENSE "$out/share/licenses/clice/LICENSE"

    runHook postInstall
  '';

  meta = {
    description = "C++ language server with native module support";
    homepage = "https://github.com/clice-io/clice";
    license = lib.licenses.asl20;
    mainProgram = "clice";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
