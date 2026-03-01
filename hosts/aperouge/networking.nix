{ config, ... }:

let
  netInterface = "enp1s0";
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
    "TS_DEBUG_FIREWALL_MODE=nftables" # tailscale
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  networking.useNetworkd = true;

  services.resolved = {
    extraConfig = ''
      DNSStubListener=no
    '';
  };

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
    };
  };
}
