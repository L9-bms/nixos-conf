let
  netInterface = "enp1s0";
in
{
  imports = [
    ../../modules/tailscale.nix
  ];

  modules.tailscale.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      53
      80
      443
    ];
  };

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

    networks = {
      "10-eno1" = {
        matchConfig.Name = netInterface;
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        # address = [ "192.168.0.2/24" ];
        # routes = [
        #   { Gateway = "192.168.0.1"; }
        # ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
