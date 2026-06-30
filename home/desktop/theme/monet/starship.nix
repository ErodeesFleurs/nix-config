{ config, themeLib }:

let
  enabled = config.programs.starship.enable;
in
themeLib.mkApp {
  enable = enabled;
  outputDirs = [ "$out/starship" ];

  generate =
    { polarity }:
    ''
      cat > "$out/starship/starship.toml" << 'TOML'
      add_newline = true
      palette = "monet"

      [character]
      success_symbol = "[➜](bold primary)"
      error_symbol = "[➜](bold error)"

      [directory]
      read_only = " 󰌾"
      style = "bold primary"
      read_only_style = "error"

      [git_branch]
      symbol = " "
      style = "secondary"

      [git_commit]
      tag_symbol = "  "
      style = "tertiary"

      [git_status]
      style = "tertiary"

      [hostname]
      ssh_symbol = " "
      style = "primary"

      [memory_usage]
      symbol = "󰍛 "
      style = "tertiary"

      [nix_shell]
      symbol = " "
      style = "secondary"

      [package]
      symbol = "󰏗 "
      style = "tertiary"

      [status]
      symbol = " "
      style = "error"

      [aws]
      symbol = " "

      [buf]
      symbol = " "

      [bun]
      symbol = " "

      [c]
      symbol = " "

      [cpp]
      symbol = " "

      [cmake]
      symbol = " "

      [conda]
      symbol = " "

      [crystal]
      symbol = " "

      [dart]
      symbol = " "

      [deno]
      symbol = " "

      [docker_context]
      symbol = " "

      [elixir]
      symbol = " "

      [elm]
      symbol = " "

      [fennel]
      symbol = " "

      [fossil_branch]
      symbol = " "

      [gcloud]
      symbol = " "

      [golang]
      symbol = " "

      [gradle]
      symbol = " "

      [guix_shell]
      symbol = " "

      [haskell]
      symbol = " "

      [haxe]
      symbol = " "

      [hg_branch]
      symbol = " "

      [java]
      symbol = " "

      [julia]
      symbol = " "

      [kotlin]
      symbol = " "

      [lua]
      symbol = " "

      [meson]
      symbol = "󰔷 "

      [nim]
      symbol = "󰆥 "

      [nodejs]
      symbol = " "

      [ocaml]
      symbol = " "

      [perl]
      symbol = " "

      [php]
      symbol = " "

      [pijul_channel]
      symbol = " "

      [pixi]
      symbol = "󰏗 "

      [python]
      symbol = " "

      [rlang]
      symbol = "󰟔 "

      [ruby]
      symbol = " "

      [rust]
      symbol = "󱘗 "

      [scala]
      symbol = " "

      [swift]
      symbol = " "

      [zig]
      symbol = " "

      [os.symbols]
      Alpaquita = " "
      Alpine = " "
      AlmaLinux = " "
      Amazon = " "
      Android = " "
      Arch = " "
      Artix = " "
      CachyOS = " "
      CentOS = " "
      Debian = " "
      DragonFly = " "
      Emscripten = " "
      EndeavourOS = " "
      Fedora = " "
      FreeBSD = " "
      Garuda = "󰛓 "
      Gentoo = " "
      HardenedBSD = "󰞌 "
      Illumos = "󰈸 "
      Kali = " "
      Linux = " "
      Mabox = " "
      Macos = " "
      Manjaro = " "
      Mariner = " "
      MidnightBSD = " "
      Mint = " "
      NetBSD = " "
      NixOS = " "
      Nobara = " "
      OpenBSD = "󰈺 "
      openSUSE = " "
      OracleLinux = "󰌷 "
      Pop = " "
      Raspbian = " "
      Redhat = " "
      RedHatEnterprise = " "
      RockyLinux = " "
      Redox = "󰀘 "
      Solus = "󰠳 "
      SUSE = " "
      Ubuntu = " "
      Unknown = " "
      Void = " "
      Windows = "󰍲 "
      TOML

      jq -r '
        def c($name): .colors[$name]["${polarity}"].color;
        [
          "",
          "[palettes.monet]",
          "primary = \"" + c("primary") + "\"",
          "secondary = \"" + c("secondary") + "\"",
          "tertiary = \"" + c("tertiary") + "\"",
          "error = \"" + c("error") + "\"",
          "surface = \"" + c("surface") + "\"",
          "on_surface = \"" + c("on_surface") + "\"",
          "on_surface_variant = \"" + c("on_surface_variant") + "\"",
          "outline = \"" + c("outline") + "\""
        ] | .[]
      ' colors.json >> "$out/starship/starship.toml"
    '';

  links = [
    {
      name = "Starship";
      target = ".config/starship.toml";
      source = "starship/starship.toml";
    }
  ];
}
