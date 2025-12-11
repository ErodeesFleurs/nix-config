{ inputs }:

let
  # 从 inputs 自动创建 overlay
  mkInputOverlay = name: input: final: prev: {
    ${name} =
      if input ? packages.${prev.system} then
        input.packages.${prev.system}
      else if input ? legacyPackages.${prev.system} then
        input.legacyPackages.${prev.system}
      else
        { };
  };

  # NUR overlays
  nurOverlays = [
    (final: prev: {
      nur = import inputs.xddxdd-nur {
        nurpkgs = prev;
        pkgs = prev;
      };
    })
    (mkInputOverlay "fleurs-nur" inputs.fleurs-nur)
  ];

  # 第三方工具 overlays
  toolOverlays = [
    # Hyprland
    inputs.hyprland.overlays.default

    # Nixcord
    (final: prev: {
      nixcord = inputs.nixcord.packages.${prev.system}.default or prev.emptyDirectory;
    })
  ];

  # 自定义包 overlays
  # 如需添加自定义包，在 ./packages/ 目录创建对应的 .nix 文件
  customOverlays = [
    (final: prev: {
      # 示例：
      # myPackage = prev.callPackage ./packages/myPackage.nix { };
    })
  ];

in
nurOverlays ++ toolOverlays ++ customOverlays
