{ config, lib, ... }:

let
  cfg = config.profiles;
in
{
  imports = [
    ./common.nix
    ./users.nix
    ./tailscale.nix
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
    (lib.mkIf (cfg.base.enable or false) {
      modules.common.enable = true;
      modules.users.enable = true;
      modules.tailscale.enable = true;
    })
  ];
}
