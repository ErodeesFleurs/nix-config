{ pkgs, ... }:

{
  # Bootloader.
  boot = {
    initrd = {
      systemd.enable = true;
    };
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];
  };
}
