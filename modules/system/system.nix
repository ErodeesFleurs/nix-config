/*
  nix-config/modules/system/system.nix
  System submodule aggregator — 聚合 system 相关子模块

  CN:
  本文件作为 system 相关子模块的聚合器。各子模块在其各自目录内声明并实现选项与行为：
    - `nix`            : Nix 相关设置（autoGC、gcOptions、substituters 等）
    - `etc`            : /etc overlay、machine-id、stateVersion、nixos-init
    - `filesystems`    : 持久化绑定挂载与额外 fileSystems 条目
    - `network/resolver`: 解析器开关（systemd-resolved / resolvconf）
    - `network/dns`    : DNS 代理 / resolver 配置

  EN:
  This file aggregates focused submodules that implement system-related configuration.
  Each submodule declares its own options and implements the corresponding configuration.
*/

{ ... }:

{
  # Import focused system submodules. Each submodule contains its own `options` and `config`.
  #
  # Submodule directories (each must contain a `default.nix`):
  #  - ../nix            : Nix-specific settings, GC implementation, substituters, trusted-users
  #  - ../etc            : /etc overlay handling, machine-id and environment defaults
  #  - ../filesystems    : bind mounts and persistent filesystem entries
  #  - ../network/resolver : networking defaults (resolvconf/resolved toggles)
  #  - ../network/dns    : dns proxy / resolver configuration (dnsproxy etc)
  #
  # CN: 导入子模块目录（每个目录应包含一个 `default.nix`），这些子模块在各自位置声明并实现选项与行为。
  imports = [
    ../nix
    ../etc
    ../filesystems
    ../network/resolver
    ../network/dns
  ];
}
