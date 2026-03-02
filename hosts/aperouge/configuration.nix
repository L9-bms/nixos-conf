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

  networking.hostName = "aperouge";
  networking.hostId = "7f580963";

  environment.systemPackages = with pkgs; [
    git
    wget
    age
    sops
    openssl
    neovim
    yazi
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/persist/sops-nix/key.txt";
  };

  users.users.callum.hashedPasswordFile = "/persist/passwd/callum";

  # DELETE
  programs.nix-ld.enable = true;
  security.sudo.wheelNeedsPassword = false;
  systemd.tmpfiles.rules = [
    "d /mnt/media 0750 root root -"
    "d /mnt/media/torrents 0750 root root -"
    "d /mnt/media/media 0750 root root -"
  ];

  system.stateVersion = "25.11";
}
