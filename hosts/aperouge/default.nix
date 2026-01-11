{ pkgs, ... }:

{
  imports = [
    ../../modules
    ./hardware-configuration.nix
  ];

  profiles.server.enable = true;
  profiles.homelab.enable = true;

  networking.hostName = "aperouge";
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

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

  sops = {
    defaultSopsFile = ../../secrets/caddy-ca.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  system.stateVersion = "25.11";
}
