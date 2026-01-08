{ ... }:

let
  # NUR overlays
  nurOverlays = [
    # (final: prev: {
    #   nur = import inputs.xddxdd-nur {
    #     nurpkgs = prev;
    #     pkgs = prev;
    #   };
    # })
    # (fleursLib.mkInputOverlay "fleurs-nur" inputs.fleurs-nur)
  ];

  # 第三方工具 overlays
  toolOverlays = [
    # Hyprland
    # inputs.hyprland.overlays.default

    # Nixcord
    # (final: prev: {
    #   nixcord = inputs.nixcord.packages.${prev.system}.default or prev.emptyDirectory;
    # })
  ];

  customOverlays = [
    (final: prev: {
      # myPackage = prev.callPackage ./packages/myPackage.nix { };
    })
  ];

in
nurOverlays ++ toolOverlays ++ customOverlays
