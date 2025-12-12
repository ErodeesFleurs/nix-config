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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fleurs-nur = {
      url = "github:ErodeesFleurs/fleurs-nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
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
      nixos-hardware,
      fleurs-nur,
      ...
    }:
    let
      system = "x86_64-linux";

      # 加载 overlays
      overlays = import ./overlays { inherit inputs; };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = overlays;
      };

      # 扩展标准库
      lib = nixpkgs.lib.extend (
        final: prev: {
          fleursLib = import ./lib {
            lib = final;
            inherit inputs;
          };
        }
      );

      specialArgs = {
        inherit inputs self;
        fleursLib = lib.fleursLib;
      };

    in
    {
      # ==========================================
      # NixOS 配置
      # 使用: nh os switch .#spectre
      # ==========================================
      nixosConfigurations.spectre = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgs;
        modules = [
          { nixpkgs.pkgs = pkgs; }
          stylix.nixosModules.stylix
          ./modules
          ./hosts/spectre
        ];
      };

      nixosConfigurations.spectre-surface = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgs;
        modules = [
          { nixpkgs.pkgs = pkgs; }
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          stylix.nixosModules.stylix
          ./modules
          ./hosts/spectre-surface
        ];
      };

      # ==========================================
      # Home Manager 配置
      # 使用: nh home switch .#fleurs
      # ==========================================
      homeConfigurations.fleurs = home-manager.lib.homeManagerConfiguration {
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

      # ==========================================
      # 导出模块
      # ==========================================
      nixosModules.default = ./modules;
      homeModules.default = ./home;

      # ==========================================
      # 格式化器
      # ==========================================
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
