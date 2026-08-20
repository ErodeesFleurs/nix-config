{ inputs, ... }:

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
    # Nixcord
    # (final: prev: {
    #   nixcord = inputs.nixcord.packages.${prev.system}.default or prev.emptyDirectory;
    # })
  ];

  customOverlays = [
    (final: prev: {
      # myPackage = prev.callPackage ./packages/myPackage.nix { };

      # curl-cffi 的测试在 Python 3.14 / 新版 curl 下失败：
      # - test_verify 断言的 SSL 错误消息与新版本 curl 不符
      # - test_delete_cookies 在 Python 3.14 下行为异常
      # 暂时禁用测试以恢复 home-manager 构建
      python314 = prev.python314.override {
        packageOverrides = pyfinal: pyprev: {
          curl-cffi = pyprev.curl-cffi.overridePythonAttrs (old: {
            doCheck = false;
          });
        };
      };
    })
  ];

in
nurOverlays ++ toolOverlays ++ customOverlays
