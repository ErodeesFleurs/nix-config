{
  description = "Fleurs's NixOS and Home Manager configuration (separated)";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://vicinae.cachix.org"
      "https://fleurs-nur.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "fleurs-nur.cachix.org-1:pmeJEXCONKeFWIFOVqG2DHMQYR87VRSmwESRy55Wt7M="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    daeuniverse = {
      url = "github:daeuniverse/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fleurs-nur = {
      url = "github:ErodeesFleurs/fleurs-nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      fleursLib = import ./lib {
        inherit (nixpkgs) lib;
        inherit inputs;
      };

      overlays = import ./overlays { inherit inputs fleursLib; };

      pkgs = import nixpkgs {
        inherit system overlays;
        # 非自由包白名单（替代全局 allowUnfree；eval 报错的包按名追加）
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            # NVIDIA 驱动栈
            "nvidia-x11"
            "nvidia-settings"
            "nvidia-persistenced"
            # 游戏
            "steam"
            "steam-unwrapped"
            "steam-run"
            "steamcmd"
            "proton-ge-bin"
            "openstarbound"
            # IM / 工具
            "qq"
            "wechat"
            "feishu"
            "baidupcs-go"
            # 输入法词库（CC BY-NC-SA）
            "fcitx5-pinyin-moegirl"
            "fcitx5-pinyin-zhwiki"
            # 微软核心字体（unfreeRedistributable）
            "corefonts"
            # osu! 官方二进制（CC BY-NC）
            "osu-lazer-bin"
            # RAR 压缩工具（共享软件）
            "rar"
          ];
      };

      specialArgs = {
        inherit inputs self fleursLib;
      };

      mkHost =
        hostDir:
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            { nixpkgs.pkgs = pkgs; }
            inputs.daeuniverse.nixosModules.dae
            inputs.daeuniverse.nixosModules.daed
            inputs.niri.nixosModules.niri
            inputs.agenix.nixosModules.default
            ./modules
            hostDir
          ];
        };

      mkHome =
        userDir:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = specialArgs;
          modules = [
            inputs.nixcord.homeModules.nixcord
            inputs.vicinae.homeManagerModules.default
            inputs.niri.homeModules.niri
            inputs.agenix.homeManagerModules.default
            ./home
            userDir
          ];
        };
    in
    {
      nixosConfigurations = {
        spectre = mkHost ./hosts/spectre;
        spectre-surface = mkHost ./hosts/spectre-surface;
      };

      homeConfigurations = {
        "fleurs@spectre" = mkHome ./users/fleurs;
        "fleurs@spectre-surface" = mkHome ./users/fleurs-surface;
      };

      packages.${system} = {
        spectre = self.nixosConfigurations.spectre.config.system.build.toplevel;
        spectre-surface = self.nixosConfigurations.spectre-surface.config.system.build.toplevel;
        fleurs = self.homeConfigurations."fleurs@spectre".activationPackage;
        fleurs-surface = self.homeConfigurations."fleurs@spectre-surface".activationPackage;
      };

      # nix fmt：treefmt 统一入口（nixfmt + deadnix --edit，见 treefmt.toml）
      formatter.${system} = pkgs.writeShellApplication {
        name = "treefmt";
        runtimeInputs = [
          pkgs.treefmt
          pkgs.nixfmt
          pkgs.deadnix
        ];
        text = ''exec treefmt --config-file ${./treefmt.toml} "$@"'';
      };

      # nix flake check 时运行的静态检查
      checks.${system} = {
        # 格式门禁：treefmt 重跑全部 formatter，有任何改动即失败
        treefmt =
          pkgs.runCommand "check-treefmt"
            {
              nativeBuildInputs = [
                pkgs.treefmt
                pkgs.nixfmt
                pkgs.deadnix
              ];
            }
            ''
              cp -r ${self} tree && chmod -R u+w tree && cd tree
              treefmt --fail-on-change --no-cache --config-file ${./treefmt.toml} --tree-root .
              touch $out
            '';
        # 语义门禁：statix/deadnix 中不可自动修复的部分
        lint =
          pkgs.runCommand "check-lint"
            {
              nativeBuildInputs = [
                pkgs.statix
                pkgs.deadnix
              ];
            }
            ''
              cd ${self}
              statix check .
              deadnix --fail .
              touch $out
            '';
      };
    };
}
