{
  description = "Fleurs's NixOS and Home Manager configuration (separated)";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://vicinae.cachix.org"
      "https://fleurs-nur.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "fleurs-nur.cachix.org-1:pmeJEXCONKeFWIFOVqG2DHMQYR87VRSmwESRy55Wt7M="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xddxdd-nur = {
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fleurs-nur = {
      url = "github:ErodeesFleurs/fleurs-nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      stylix,
      nixcord,
      vicinae,
      agenix,
      ...
    }:
    let
      system = "x86_64-linux";

      # 加载 overlays
      overlays = import ./overlays { inherit inputs; };

      # 先导入基础 pkgs，命名为 basePkgs，避免后面重定义同名变量
      basePkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = overlays;
      };

      # 扩展 nixpkgs.lib（而非 basePkgs.lib），这样扩展后的 lib 会包含 nixosSystem
      finalLib = nixpkgs.lib.extend (
        final: prev: {
          fleursLib = import ./lib {
            lib = final;
            inherit inputs;
          };
        }
      );

      # 把扩展后的 lib 注入到 pkgs（使得 pkgs.lib == finalLib）
      pkgs = basePkgs // {
        lib = finalLib;
      };

      # 扩展 home-manager 的 lib（以便 Home Manager 模块也能直接用 fleursLib）
      finalHomeLib = home-manager.lib.extend (
        final: prev: {
          fleursLib = finalLib.fleursLib;
        }
      );

      specialArgs = {
        inherit inputs self;
        fleursLib = finalLib.fleursLib;
      };

    in
    {
      # ==========================================
      # NixOS 配置
      # 使用: nh os switch .#spectre
      # ==========================================
      nixosConfigurations.spectre = finalLib.nixosSystem {
        inherit system;
        specialArgs = specialArgs;
        modules = [
          { nixpkgs.pkgs = pkgs; }
          stylix.nixosModules.stylix
          ./modules
          ./hosts/spectre
        ];
      };

      # 使用: nh os switch .#spectre-surface
      nixosConfigurations.spectre-surface = finalLib.nixosSystem {
        inherit system;
        specialArgs = specialArgs;
        modules = [
          { nixpkgs.pkgs = pkgs; }
          stylix.nixosModules.stylix
          ./modules
          ./hosts/spectre-surface
        ];
      };

      # ==========================================
      # Home Manager 配置
      # 使用: nh home switch .#fleurs
      # ==========================================
      home-manager.backupFileExtension = "backup";
      homeConfigurations.fleurs = finalHomeLib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = specialArgs;
        modules = [
          stylix.homeModules.stylix
          nixcord.homeModules.nixcord
          vicinae.homeManagerModules.default
          agenix.homeManagerModules.default
          ./home
          ./users/fleurs
        ];
      };

      # 使用: nh home switch .#fleurs-surface
      homeConfigurations.fleurs-surface = finalHomeLib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = specialArgs;
        modules = [
          stylix.homeModules.stylix
          nixcord.homeModules.nixcord
          vicinae.homeManagerModules.default
          agenix.homeManagerModules.default
          ./home
          ./users/fleurs-surface
        ];
      };

      # ==========================================
      # 导出模块
      # ==========================================
      nixosModules.default =
        { lib, ... }:
        (import ./modules {
          inherit lib;
          inputs = { };
        });
      homeModules.default =
        { lib, ... }:
        (import ./home {
          inherit lib;
          inputs = { };
        });

      # ==========================================
      # 格式化器
      # ==========================================
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
