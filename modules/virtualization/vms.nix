{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.virtualization.vms;

  vmConfigs = [
    ./vms/arr-stack.nix
  ];

  vmNames = map (vm: (import vm { inherit lib; }).networking.hostName) vmConfigs;
in
{
  options.modules.virtualization.vms.enable = lib.mkEnableOption "Homelab MicroVMs";

  config = lib.mkIf cfg.enable {
    microvm = {
      autostart = vmNames;
      vms = builtins.listToAttrs (
        map (
          vmConfig:
          let
            vm = import vmConfig { inherit lib; };
          in
          {
            name = vm.networking.hostName;
            value = {
              inherit pkgs;
              config = vmConfig;
            };
          }
        ) vmConfigs
      );
    };
  };
}
