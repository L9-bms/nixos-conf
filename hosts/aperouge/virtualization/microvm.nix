{
  lib,
  pkgs,
  ...
}:

let
  vmConfigs = [
    ./microvms/dmz.nix
    ./microvms/forgejo-runner.nix
  ];

  vmNames = map (vm: (import vm { inherit lib pkgs; }).networking.hostName) vmConfigs;
in
{
  microvm = {
    autostart = vmNames;
    vms = builtins.listToAttrs (
      map (
        vmConfig:
        let
          vm = import vmConfig { inherit lib pkgs; };
        in
        {
          name = vm.networking.hostName;
          value = {
            config = vmConfig;
          };
        }
      ) vmConfigs
    );
  };

  # to access zvols
  users.users.microvm.extraGroups = [ "disk" ];
}
