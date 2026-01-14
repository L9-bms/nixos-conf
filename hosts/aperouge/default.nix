{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules

    ./networking.nix
    ./persistence.nix

    ./virtualization/libvirt.nix
    ./virtualization/microvm.nix

    ./services
  ];

  profiles.base.enable = true;
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "aperouge";
  networking.hostId = "7f580963";

  programs.nix-ld.enable = true;

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

  # DELETE
  security.sudo.wheelNeedsPassword = false;
  systemd.tmpfiles.rules = [
    "d /mnt/media 0750 root root -"
  ];

  users.users.callum.hashedPasswordFile = "/persist/passwd/callum";

  system.stateVersion = "25.11";
}
