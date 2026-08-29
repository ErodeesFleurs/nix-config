{ fleursLib, ... }:

{
  # desktop/theme/monet 由 darkman.nix 带参手动 import，不能作为普通模块加载
  imports = fleursLib.importDir ./. {
    exclude = [ ./desktop/theme/monet ];
  };

  # 不构建 HM 手册页（每次 activation 省几秒）
  manual = {
    html.enable = false;
    manpages.enable = false;
    json.enable = false;
  };

  # activation 不打印 news 条目
  news.display = "silent";
}
