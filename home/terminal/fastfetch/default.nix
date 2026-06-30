{ ... }:

{
  # Logo 文件配置
  home.file.".config/fastfetch/logo" = {
    source = ./logo;
    recursive = true;
    executable = true;
  };

  # Fastfetch 程序配置
  programs.fastfetch = {
    enable = true;
  };
}
