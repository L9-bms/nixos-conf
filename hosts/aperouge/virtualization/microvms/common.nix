{ config, lib, ... }:

let
  cfg = config.vm;
in
{
  options.vm = {
    index = lib.mkOption {
      type = lib.types.int;
      description = "Index (determines IP address)";
    };

    mac = lib.mkOption {
      type = lib.types.str;
      description = "MAC address";
    };

    mem = lib.mkOption {
      type = lib.types.int;
      description = "Memory in MB";
    };
  };

  config = {
    # TODO: add host ssh key
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/QBkbelaWRpHNIFUqmj3KoFKW0iGdMYVviT+7iSFH/ callum@aperouge"
    ];

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    microvm = {
      mem = cfg.mem;

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
          id = "vm${toString cfg.index}";
          type = "tap";
          mac = cfg.mac;
        }
      ];

      hypervisor = "qemu";
      socket = "control.socket";
    };

    networking.useNetworkd = true;

    systemd.network.networks."10-eth" = {
      matchConfig.MACAddress = cfg.mac;
      address = [
        "10.0.0.${toString cfg.index}/32"
        "fec0::${lib.toHexString cfg.index}/128"
      ];
      routes = [
        # host route - need to find way to add this as needed
        # {
        #   Destination = "10.0.0.0/32";
        #   GatewayOnLink = true;
        # }
        {
          Destination = "0.0.0.0/0";
          Gateway = "10.0.0.0";
          GatewayOnLink = true;
        }
        {
          Destination = "::/0";
          Gateway = "fec0::";
          GatewayOnLink = true;
        }
      ];
      networkConfig = {
        DNS = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
    };

    system.stateVersion = "25.11";
  };
}
