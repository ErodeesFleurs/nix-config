{ lib, ... }:

let
  fleursLib =
    lib.fleursLib or (import ../lib {
      inherit lib;
      inputs = { };
    });
in
{
  imports = fleursLib.importDir ./.;
}
