{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    prism-tower.url = "github:L9-bms/prism-tower";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      sops-nix,
      disko,
      impermanence,
      deploy-rs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      nixpkgs-patched = (import nixpkgs-unstable { inherit system; }).applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs-unstable;
        patches = [ ];
      };
    in
    {
      nixosConfigurations = {
        liz = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/liz/configuration.nix
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
          ];
        };
        wky = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          pkgs = import nixpkgs-patched {
            inherit system;
            config = {
              allowUnfree = true;
              allowInsecurePredicate =
                pkg:
                builtins.elem (nixpkgs-unstable.lib.getName pkg) [
                  "broadcom-sta"
                ];
            };
          };
          modules = [
            ./hosts/wky/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.backupFileExtension = "backup";

              home-manager.users.callum = ./hosts/wky/home.nix;
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };

      deploy.nodes.liz = {
        hostname = "liz";
        profiles.system = {
          sshUser = "callum";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.liz;
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
