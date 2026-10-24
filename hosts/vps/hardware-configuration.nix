# Observed on 198.44.178.249: Dell PowerEdge C6320, UEFI, AHCI, ixgbe.
{ lib, ... }:
{
  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "ehci_pci"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [
      "kvm-intel"
      "ixgbe"
    ];
    kernelParams = [
      "console=tty0"
      "console=ttyS0,115200n8"
      "consoleblank=0"
    ];
    loader = {
      timeout = 5;
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };
      # Keep kernels on the ext4 /boot, not the existing 124 MiB ESP.
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        configurationLimit = 5;
        extraConfig = ''
          serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
          terminal_input console serial
          terminal_output console serial
        '';
      };
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/58dd5456-f0e0-45ce-a7fe-028c84332cb0";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/7D87-0B8D";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };
  swapDevices = [
    {
      device = "/var/lib/osbswap/swapfile";
      priority = 10;
    }
  ];
  hardware.cpu.intel.updateMicrocode = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
