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
        config.allowUnfree = true;
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

      formatter.${system} = pkgs.nixfmt-tree;

      # nix flake check 时运行的静态检查
      checks.${system} =
        let
          mkCheck =
            name: nativeBuildInputs: script:
            pkgs.runCommand "check-${name}" { inherit nativeBuildInputs; } ''
              cd ${self}
              ${script}
              touch $out
            '';
        in
        {
          nixfmt = mkCheck "nixfmt" [ pkgs.nixfmt ] ''
            failed=0
            while IFS= read -r f; do
              nixfmt --check "$f" || failed=1
            done < <(find . -name '*.nix' -type f)
            [ "$failed" -eq 0 ]
          '';
          statix = mkCheck "statix" [ pkgs.statix ] ''
            statix check .
          '';
          deadnix = mkCheck "deadnix" [ pkgs.deadnix ] ''
            deadnix --fail .
          '';
        };
    };
}
