{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        aperouge = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          # > Our main nixos configuration file <
          modules = [ ./homelab/configuration.nix ];
        };
      };
    };
}
