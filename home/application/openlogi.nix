{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeModules.openlogi;
  darkman = config.homeModules.desktop.darkman;
  python = pkgs.python3.withPackages (ps: [ ps.tomlkit ]);
  mergePreferences = pkgs.writeText "openlogi-monet-preferences.py" ''
    import fcntl
    import os
    from pathlib import Path
    import sys
    import tempfile

    import tomlkit

    # Match OpenLogi's stable config.toml.lock inode, including symlink aliases.
    # Lock before reading; never unlink the sidecar when releasing the lock.
    target = Path(sys.argv[1]).resolve()
    target.parent.mkdir(parents=True, exist_ok=True)
    with open(str(target) + ".lock", "a+") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        try:
            original = target.read_text(encoding="utf-8")
            document = tomlkit.parse(original)
        except FileNotFoundError:
            original = None
            document = tomlkit.document()
            # Locked OpenLogi 0.8.13 requires the schema even in a minimal file.
            document["schema_version"] = 7

        if "app_settings" not in document:
            document["app_settings"] = tomlkit.table()
        settings = document["app_settings"]
        settings["appearance"] = "system"
        settings["theme_light"] = "Monet MD3 Light"
        settings["theme_dark"] = "Monet MD3 Dark"
        updated = tomlkit.dumps(document)

        # Preserve every other preference, binding, schema and comment. The file
        # remains app-owned and writable, rather than a Home Manager store link.
        if updated != original:
            temporary = None
            try:
                with tempfile.NamedTemporaryFile(
                    mode="w", encoding="utf-8", dir=target.parent,
                    prefix=".config.toml.", delete=False,
                ) as output:
                    temporary = Path(output.name)
                    os.fchmod(output.fileno(), 0o600)
                    output.write(updated)
                    output.flush()
                    os.fsync(output.fileno())
                os.replace(temporary, target)
            finally:
                if temporary is not None:
                    temporary.unlink(missing_ok=True)
  '';
in
{
  # The system module installs the patched package and scoped device permissions.
  # This switch only integrates the existing app with the Home Manager theme.
  options.homeModules.openlogi.enable = lib.mkEnableOption "OpenLogi Monet integration";

  config = lib.mkIf (cfg.enable && darkman.enable && darkman.monet.enable) {
    home.activation.configureOpenLogiMonet =
      lib.hm.dag.entryAfter
        [
          "writeBoundary"
          "linkOpenLogiTheme"
        ]
        ''
          # With no wallpaper, Darkman generates static styles but no app palettes.
          # Do not replace a user's theme choices with unavailable Monet names.
          if [ -r ${lib.escapeShellArg "${config.xdg.configHome}/openlogi/monet.json"} ]; then
            run ${python}/bin/python ${mergePreferences} \
              ${lib.escapeShellArg "${config.xdg.configHome}/openlogi/config.toml"}
          fi
        '';
  };
}
