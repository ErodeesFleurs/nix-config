{ lib, ... }:

let
  fleursLib = lib.fleursLib;
in
{
  imports = fleursLib.importDir ./.;
}
