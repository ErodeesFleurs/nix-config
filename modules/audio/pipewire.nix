{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.pipewire;
in
{
  options.modules.pipewire = {
    enable = lib.mkEnableOption "PipeWire audio system";

    alsa32Bit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable 32-bit ALSA support";
    };

    pulse = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PulseAudio compatibility";
    };
  };

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      audio.enable = true;

      alsa = {
        enable = true;
        support32Bit = cfg.alsa32Bit;
      };

      pulse.enable = cfg.pulse;
    };
  };
}
