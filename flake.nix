{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      ...
    }@inputs:
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        aperouge = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          # > Our main nixos configuration file <
          modules = [
            ./homelab/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
