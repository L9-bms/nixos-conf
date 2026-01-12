{ config, lib, ... }:

let
  cfg = config.profiles;
in
{
  imports = [
    ./common.nix
    ./users.nix
    ./services/definitions.nix
    ./services/gateway.nix
    ./services/monitoring.nix
    ./virtualization/vms.nix
    ./virtualization/networking.nix
  ];

  options.profiles = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.enable = lib.mkEnableOption "Enable this system profile.";
      }
    );
    default = { };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.server.enable or false) {
      modules.common.enable = true;
      modules.users.enable = true;
      modules.tailscale.enable = true;
    })

    (lib.mkIf (cfg.homelab.enable or false) {
      modules.services.gateway.enable = true;
      modules.services.monitoring.enable = true;
      modules.virtualization.vms.enable = true;
      modules.virtualization.networking.enable = true;
    })
  ];
}
