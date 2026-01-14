{
  lib,
  pkgs,
  ...
}:

let
  vmConfigs = [
    ./microvms/arr-stack.nix
  ];

  vmNames = map (vm: (import vm { inherit lib; }).networking.hostName) vmConfigs;
in
{
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

  # to access zvols
  users.users.microvm.extraGroups = [ "disk" ];
}
