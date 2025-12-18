{ lib, ... }:

let
  fleursLib =
    lib.fleursLib or (import ../../lib {
      inherit lib;
      inputs = { };
    });
in
{
  # Import every submodule directory under `modules/programs` automatically.
  # 子目录中每个模块应包含 `default.nix`，并由此处统一导入。
  imports = fleursLib.importDir ./.;
}
