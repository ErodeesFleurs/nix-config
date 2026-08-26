{ fleursLib, ... }:

{
  # desktop/theme/monet 由 darkman.nix 带参手动 import，不能作为普通模块加载
  imports = fleursLib.importDir ./. {
    exclude = [ ./desktop/theme/monet ];
  };
}
