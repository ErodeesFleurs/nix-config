{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      font-awesome

      source-code-pro
      source-han-sans
      source-han-serif
      source-han-mono

      sarasa-gothic

      corefonts

      vista-fonts
      vista-fonts-cht
      vista-fonts-chs

      wqy_microhei
      wqy_zenhei

      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
      nerd-fonts.symbols-only
      nerd-fonts.dejavu-sans-mono
    ];
    # 设置 fontconfig 防止出现乱码
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [
          "Noto Color Emoji"
        ];
        monospace = [
          "wqy-zenhei"
          "Noto Sans Mono CJK SC"
          "CaskaydiaCove NF"
          "Sarasa Mono SC"
          "DejaVu Sans Mono"
        ];
        sansSerif = [
          "wqy-zenhei"
          "Noto Sans CJK SC"
          "Source Han Sans SC"
          "DejaVu Sans"
        ];
        serif = [
          "wqy-zenhei"
          "Noto Serif CJK SC"
          "Source Han Serif SC"
          "DejaVu Serif"
        ];
      };
    };
  };
}
