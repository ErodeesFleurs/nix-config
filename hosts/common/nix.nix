# Nix 子系统设置（GC 由 nh clean 管理，见 programs.nix）
{ ... }:

{
  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      trusted-users = [ "fleurs" ];
      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [ ];

      # 写入 store 时即时硬链接去重（替代周期性全店扫描）
      auto-optimise-store = true;
    };
  };
}
