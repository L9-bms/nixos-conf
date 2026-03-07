{ pkgs, config, ... }:

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
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  };

  sops.secrets."passwords/callum" = {
    owner = "root";
    group = "root";
    mode = "0400";
    neededForUsers = true;
  };
  users.users.callum.hashedPasswordFile = config.sops.secrets."passwords/callum".path;

  nix.settings.trusted-users = [ "callum" ];

  security.sudo.extraConfig = ''
    Defaults lecture = always
    Defaults lecture_file = ${pkgs.writeText "sudo-lecture" ''
      A friendly reminder:

      This system is managed by NixOS. Direct modifications
      to the system will be lost. The root filesystem is
      ephemeral and wiped on every boot.

      Make changes to /persist/nixos-conf instead.
    ''}
  '';

  users.users.colin = {
    isNormalUser = true;
  };

  system.stateVersion = "25.11";
}
