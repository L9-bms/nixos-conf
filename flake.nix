{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    prism-tower.url = "github:L9-bms/prism-tower";

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      microvm,
      disko,
      disko-zfs,
      impermanence,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        aperouge = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/aperouge
            sops-nix.nixosModules.sops
            microvm.nixosModules.host
            disko.nixosModules.disko
            disko-zfs.nixosModules.default
            impermanence.nixosModules.impermanence
          ];
        };
      };
    };
}
