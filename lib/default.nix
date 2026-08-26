{ lib, ... }:

{
  # 递归导入目录中的所有 .nix 文件和子目录
  importDir =
    dir:
    let
      files = builtins.readDir dir;
      nixFiles = lib.filterAttrs (
        name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
      ) files;
      subdirs = lib.filterAttrs (name: type: type == "directory") files;
    in
    (lib.mapAttrsToList (name: _: dir + "/${name}") nixFiles)
    ++ (lib.mapAttrsToList (name: _: dir + "/${name}") subdirs);
}
