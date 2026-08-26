{ lib, ... }:

{
  # 递归收集目录下的所有 .nix 文件（深入子目录）：
  # - 根目录的 default.nix 被跳过（即调用者自身），子目录的 default.nix 照常收集
  # - exclude 中的子目录被整体跳过（例如被手动带参 import 的库目录）
  importDir =
    dir:
    {
      exclude ? [ ],
    }:
    let
      excluded = map toString exclude;

      go =
        d: isRoot:
        let
          entries = builtins.readDir d;
          files = lib.filterAttrs (
            name: type: type == "regular" && lib.hasSuffix ".nix" name && !(isRoot && name == "default.nix")
          ) entries;
          subdirs = lib.filterAttrs (name: type: type == "directory") entries;
        in
        (lib.mapAttrsToList (name: _: d + "/${name}") files)
        ++ lib.concatMap (
          name:
          let
            sub = d + "/${name}";
          in
          lib.optionals (!(builtins.elem (toString sub) excluded)) (go sub false)
        ) (builtins.attrNames subdirs);
    in
    go dir true;
}
