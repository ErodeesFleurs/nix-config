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
    };

    optimise.automatic = true;
  };
}
