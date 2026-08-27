{ ... }:

{
  # Logo 文件配置（builtins.path：内容寻址，避免仓库改动改变 store 路径）
  home.file.".config/fastfetch/logo" = {
    source = builtins.path {
      path = ./logo;
      name = "fastfetch-logo";
    };
    recursive = true;
  };

  programs.fastfetch = {
    enable = true;
  };
}
