{ ... }:
{

  security.polkit.enable = true;

  security = {
    sudo.enable = false;
    sudo-rs = {
      enable = true;
    };
  };
}
