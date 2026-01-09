# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  networking.hostName = "aperouge";
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;

  time.timeZone = "Australia/Sydney";

  console.font = "Lat2-Terminus16";

  users.users = {
    callum = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDbohv1UoLyc7mfaho1z/JDe14DH4sDj+rc6vLr4d1HZ4J6LKsR9r7o3ZIsw2AIvT0g3VOCjWxVv2JoFkbUS07HE9i/gVp8R+/Z3zZsNhX7jEL+CUaqTgjqKp1QUHMDA1+Y5F7gxshVfk1HyZmrnKbJarux3r2NA+rVj4c7Fm7wh8J/irGUzicJO94vU9ASYc6RLWEJZNuwLxEOFJ9VrfhFAp+ERZvBvLiWk6Gr2B8r5jw056t2rhcQETgyQH79i92c18Vy0L33NZ/ltPGybRKqnZS9vpLjtIPsHA7iJT/9b8CLwlEm/Esg5sUthzCdNDXo48mtxdoq99Fcor450+VxLm6NnM18SBKx/mv+CKcob69Yzr10A1948mNs6Yjj3v4zbIlOv9egv3c2Wxr56DoZxOWSB0CF4PYn2pYvIrs20czRRoz6wuCevqXDb9aCq05L/yyJGpMjVy6fp1BCDeeKblvxaZDwPXqtwsNhkpS7m5KHDxGwSr6UjIaQlbMS7/k= callum@CallumPC"
      ];
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
        neovim
      ];
    };
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
