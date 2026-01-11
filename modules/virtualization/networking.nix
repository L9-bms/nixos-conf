{ config, lib, ... }:

let
  cfg = config.modules.virtualization.networking;
  maxVMs = 8;
in
{
  options.modules.virtualization.networking.enable =
    lib.mkEnableOption "Host networking for isolated VMs";

  config = lib.mkIf cfg.enable {
    networking.useNetworkd = true;

    systemd.network.networks = builtins.listToAttrs (
      map (index: {
        name = "30-vm${toString index}";
        value = {
          matchConfig.Name = "vm${toString index}";
          address = [
            "10.0.0.0/32"
            "fec0::/128"
          ];
          routes = [
            { Destination = "10.0.0.${toString index}/32"; }
            { Destination = "fec0::${lib.toHexString index}/128"; }
          ];
          networkConfig = {
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
        };
      }) (lib.genList (i: i + 1) maxVMs)
    );

    networking.nat = {
      enable = true;
      internalIPs = [ "10.0.0.0/24" ];
      # must set networking.nat.externalInterface on host config
    };
  };
}

# from https://microvm-nix.github.io/microvm.nix/routed-network.html
