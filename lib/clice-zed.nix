{
  lib,
  fetchFromGitHub,
  fetchurl,
  pkgsCross,
  lld,
  wasm-tools,
}:

let
  # Zed loads components, not the core module emitted by wasm32-wasip1.
  wasiAdapter = fetchurl {
    url = "https://github.com/bytecodealliance/wasmtime/releases/download/v30.0.2/wasi_snapshot_preview1.reactor.wasm";
    hash = "sha256-BYocDKOrsq4B8f4wNbkACMksPvJCFP1HkGRjx5/GpYs=";
  };
in
pkgsCross.wasm32-wasip1.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clice-zed";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "clice-io";
    repo = "clice";
    rev = "ec5b90e1617bda438e794aa1ac3a84da21b00be5";
    hash = "sha256-UHNj3Vu6bXZDJ08AOHrtaOMM+hZzMohhR0Q+ckMZGBw=";
  };

  sourceRoot = "${finalAttrs.src.name}/editors/zed";
  cargoLock.lockFile = "${finalAttrs.src}/editors/zed/Cargo.lock";

  strictDeps = true;
  nativeBuildInputs = [ wasm-tools ];

  # The cross Rust platform supplies the WASI standard library; use the native
  # linker explicitly instead of depending on rust-lld inside the Rust sysroot.
  env.RUSTFLAGS = "-C linker=${lld}/bin/wasm-ld";
  cargoBuildFlags = [
    "--locked"
    "--lib"
  ];

  auditable = false;
  doCheck = false;
  # Preserve the component metadata and zed:api-version custom section.
  dontStrip = true;

  postBuild = ''
    wasm-tools component new target/wasm32-wasip1/release/zed_clice.wasm \
      --adapt wasi_snapshot_preview1=${wasiAdapter} \
      --output extension.wasm
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 extension.toml "$out/extension.toml"
    install -Dm644 extension.wasm "$out/extension.wasm"
    install -Dm644 LICENSE "$out/LICENSE"
    runHook postInstall
  '';

  meta = {
    description = "Official Clice language-server extension for Zed";
    homepage = "https://github.com/clice-io/clice/tree/${finalAttrs.src.rev}/editors/zed";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
