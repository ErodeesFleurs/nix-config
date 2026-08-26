# 引导配置（主机特定项：kernelParams 在各 host 中设置）
{ lib, pkgs, ... }:

{
  boot = {
    initrd.systemd.enable = true;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
