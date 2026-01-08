{ lib, ... }:

rec {
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

  # 创建带 enable 选项的模块
  mkEnableModule =
    name: extraOptions:
    { lib, ... }:
    with lib;
    {
      options.${name}.enable = mkEnableOption name // extraOptions;
    };

  # 自动导入目录为模块列表
  autoImport = dir: map (f: import f) (importDir dir);

  # 条件导入：如果路径存在则导入
  optionalImport = path': if lib.pathExists path' then [ path' ] else [ ];

  # 从目录中过滤并导入特定模块
  importModules =
    dir: modules:
    let
      allFiles = builtins.readDir dir;
    in
    lib.mapAttrsToList (name: _: dir + "/${name}") (
      lib.filterAttrs (
        name: type: (type == "directory" || lib.hasSuffix ".nix" name) && lib.elem name modules
      ) allFiles
    );

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

  # 快捷创建简单的 enable option
  mkBoolOpt =
    default: description:
    lib.mkOption {
      type = lib.types.bool;
      inherit default description;
    };

  # 快捷创建字符串选项
  mkStrOpt =
    default: description:
    lib.mkOption {
      type = lib.types.str;
      inherit default description;
    };

  # 快捷创建列表选项
  mkListOpt =
    default: description: elemType:
    lib.mkOption {
      type = lib.types.listOf elemType;
      inherit default description;
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
