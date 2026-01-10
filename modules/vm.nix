{
  lib,
  microvm,
  ...
}:

let
  index = 1;
  mac = "00:00:00:00:00:01";
in
{
  microvm = {
    autostart = [ "arr-vm" ];
    vms = {
      arr-vm = {
        config = {
          networking.hostName = "arr-vm";
          users.users.root.password = "password";

          microvm = {
            shares = [
              {
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
                tag = "ro-store";
                proto = "virtiofs";
              }
            ];

            interfaces = [
              {
                id = "vm${toString index}";
                type = "tap";
                inherit mac;
              }
            ];

            hypervisor = "qemu";
            socket = "control.socket";
          };

          services.openssh.enable = true;
          services.openssh.settings.PermitRootLogin = "yes";

          networking.useNetworkd = true;

          systemd.network.networks."10-eth" = {
            matchConfig.MACAddress = mac;
            # Static IP configuration
            address = [
              "10.0.0.${toString index}/32"
              "fec0::${lib.toHexString index}/128"
            ];
            routes = [
              {
                # A route to the host
                Destination = "10.0.0.0/32";
                GatewayOnLink = true;
              }
              {
                # Default route
                Destination = "0.0.0.0/0";
                Gateway = "10.0.0.0";
                GatewayOnLink = true;
              }
              {
                # Default route
                Destination = "::/0";
                Gateway = "fec0::";
                GatewayOnLink = true;
              }
            ];
            networkConfig = {
              # DNS servers no longer come from DHCP nor Router
              # Advertisements. Perhaps you want to change the defaults:
              DNS = [
                # Quad9.net
                "9.9.9.9"
                "149.112.112.112"
                "2620:fe::fe"
                "2620:fe::9"
              ];
            };
          };
        };
      };
    };
  };
}
