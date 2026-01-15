{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  networking.hostName = "forgejo-runner";

  vm = {
    index = 2;
    mac = "00:00:00:00:00:02";
    mem = 4000;
  };

  microvm.volumes = [
    {
      image = "/dev/zvol/rpool/vms/forgejo-runner";
      mountPoint = "/";
      size = 10240;
    }
  ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      fixed-cidr-v6 = "fd00::/80";
      ipv6 = true;
    };
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.my-forgejo-instance = {
      enable = true;
      name = "my-forgejo-runner-01";
      token = "<registration-token>";
      url = "https://code.forgejo.org/";
      labels = [
        "node-22:docker://node:22-bookworm"
        "nixos-latest:docker://nixos/nix"
      ];
      settings = { };
    };
  };

  networking.firewall.trustedInterfaces = [ "br-+" ];
}

# https://bkiran.com/blog/deploying-containers-nixos
