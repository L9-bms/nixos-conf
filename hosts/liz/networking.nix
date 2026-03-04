{ pkgs, ... }:

let
  netInterface = "eno1";
in
{
  imports = [
    ../../modules/tailscale.nix
  ];

  modules.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      22
      53
      80
      443
    ];
  };

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  services.networkd-dispatcher = {
    enable = true;
    rules."50-tailscale-optimizations" = {
      onState = [ "routable" ];
      script = ''
        ${pkgs.ethtool}/bin/ethtool -K ${netInterface} rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  networking.useNetworkd = true;

  services.resolved = {
    extraConfig = ''
      DNSStubListener=no
    '';
  };

  systemd.network = {
    enable = true;

    networks = {
      "10-eno1" = {
        matchConfig.Name = netInterface;
        address = [ "192.168.0.2/24" ];
        routes = [
          { Gateway = "192.168.0.1"; }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
