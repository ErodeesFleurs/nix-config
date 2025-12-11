{ ... }:

{
  powerManagement = {
    enable = true;
    powertop = {
      enable = true;
    };
  };

  services.upower = {
    enable = true;
  };
}
