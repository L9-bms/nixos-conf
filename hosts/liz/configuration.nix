{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/base.nix
    ../../modules/users.nix

    ./networking.nix
    ./persistence.nix

    ./services
  ];

  modules.base.enable = true;
  modules.users.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" ];

  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/0b878ab4-2310-4b8e-92e8-7ef5f47f75f8";
    fsType = "ext4";
  };

  networking.hostName = "liz";
  networking.hostId = "19550836";

  environment.systemPackages = with pkgs; [
    git
    wget
    age
    sops
    openssl
    neovim
    yazi
    ethtool
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/persist/sops-nix/key.txt";
  };

  users.users.callum.hashedPasswordFile = "/persist/passwd/callum";
  users.users.callum.initialPassword = "password";

  users.users.colin = {
    isNormalUser = true;
  };

  system.stateVersion = "25.11";
}
