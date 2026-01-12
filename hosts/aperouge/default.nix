{ pkgs, ... }:

{
  imports = [
    ../../modules
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  profiles.server.enable = true;
  profiles.homelab.enable = true;

  networking.hostName = "aperouge";
  networking.hostId = "7f580963";
  
  boot.loader.systemd-boot.enable = true;

  fileSystems."/persist".neededForBoot = true;

  console.earlySetup = true;
  systemd.services.systemd-vconsole-setup.unitConfig.After = "local-fs.target";
  boot.initrd.systemd = {
    enable = true;
    services.initrd-rollback-root = {
      after = [ "zfs-import-rpool.service" ];
      wantedBy = [ "initrd.target" ];
      before = [
        "sysroot.mount"
      ];
      path = [ pkgs.zfs ];
      description = "Rollback root fs";
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = "zfs rollback -r rpool/nixos/root@blank";
    };
  };
  # https://notthebe.ee/blog/nixos-ephemeral-zfs-root/

  # for vscode remote server...
  programs.nix-ld.enable = true;

  networking.nat.externalInterface = "enp1s0";

  systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp1s0";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    age
    sops
    openssl
  ];

  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
    {
      path = "/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = "4096";
    }
  ];

  environment.persistence."/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/machine-id"
      "/etc/shadow"
    ];
    directories = [
      "/var/lib/tailscale"
      "/var/lib/nixos"
    ];
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/persist/sops-nix/key.txt";
  };

  system.stateVersion = "25.11";
}
