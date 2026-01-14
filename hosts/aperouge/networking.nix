{ config, lib, ... }:

let
  netInterface = "enp1s0";
  maxMicroVMs = 8;
in
{
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [
      22
      53
      80
      443
    ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  networking.useNetworkd = true;

  systemd.network = {
    enable = true;

    netdevs = {
      "20-br0".netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
    };
    networks = {
      "10-eno1" = {
        matchConfig.Name = netInterface;
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "20-br0" = {
        matchConfig.Name = "br0";
        bridgeConfig = { };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        # address = [ "192.168.0.2/24" ];
        # routes = [
        #   {
        #     Gateway = "192.168.0.1";
        #   }
        # ];
        linkConfig.RequiredForOnline = "routable";
      };
    }
    // builtins.listToAttrs (
      # from https://microvm-nix.github.io/microvm.nix/routed-network.html
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
      }) (lib.genList (i: i + 1) maxMicroVMs)
    );
  };

  networking.nat = {
    enable = true;
    externalInterface = "br0";
    internalIPs = [ "10.0.0.0/24" ];
  };
}
