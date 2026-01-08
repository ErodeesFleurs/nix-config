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

  # 为主机创建通用配置
  mkHostConfig =
    {
      hostname,
      system ? "x86_64-linux",
      modules ? [ ],
      users ? [ ],
    }:
    {
      inherit system modules;
      hostName = hostname;
      users = users;
    };

  # 为用户创建通用配置
  mkUserConfig =
    {
      username,
      homeDirectory ? "/home/${username}",
      stateVersion ? "26.05",
      extraPackages ? [ ],
      extraModules ? [ ],
    }:
    {
      inherit username homeDirectory stateVersion;
      packages = extraPackages;
      modules = extraModules;
    };

  # 创建输入覆盖层
  mkInputOverlay = name: input: final: prev: {
    ${name} =
      if input ? packages.${prev.system} then
        input.packages.${prev.system}
      else if input ? legacyPackages.${prev.system} then
        input.legacyPackages.${prev.system}
      else
        { };
  };
}
