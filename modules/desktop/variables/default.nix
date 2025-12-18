/*
  nix-config/modules/system/variables.nix
  Global environment variables — 全局环境变量

  CN: 本文件用于声明系统范围内的环境变量（sessionVariables）。
      将常用的会话/桌面相关环境变量集中放在此处，便于维护与审阅。
  EN: This file declares global environment/session variables used by the system.
      Keep common session/desktop environment variables here for maintainability.

  Notes / 说明:
  - 使用时请确保变量不会与其它模块重复定义，以免引发不必要的覆盖。
  - When adding variables, prefer descriptive names and document their purpose in CN/EN.
*/

{ ... }:

{
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_IM_MODULE = "fcitx";
    };
  };
}
