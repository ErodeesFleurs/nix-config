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
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

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

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xddxdd-nur = {
      url = "github:xddxdd/nur-packages";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      nixcord,
      vicinae,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      fleursLib = import ./lib {
        lib = nixpkgs.lib;
        inherit inputs;
      };

      overlays = import ./overlays { inherit inputs fleursLib; };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = overlays;
      };

      specialArgs = {
        inherit inputs self fleursLib;
      };

    in
    {
      nixosConfigurations."spectre" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgs;
        modules = [
          { nixpkgs.pkgs = pkgs; }
          stylix.nixosModules.stylix
          ./modules
          ./hosts/spectre
        ];
      };

      nixosConfigurations."spectre-surface" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgs;
        modules = [
          { nixpkgs.pkgs = pkgs; }
          stylix.nixosModules.stylix
          ./modules
          ./hosts/spectre-surface
        ];
      };

      homeConfigurations."fleurs@spectre" = home-manager.lib.homeManagerConfiguration {
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

      homeConfigurations."fleurs@spectre-surface" = home-manager.lib.homeManagerConfiguration {
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

      packages.${system} = {
        spectre = self.nixosConfigurations."spectre";
        spectre-surface = self.nixosConfigurations."spectre-surface";
        fleurs = self.homeConfigurations."fleurs@spectre".activationPackage;
        fleurs-surface = self.homeConfigurations."fleurs@spectre-surface".activationPackage;
      };

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

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
