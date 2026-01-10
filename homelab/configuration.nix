{
  inputs,
  lib,
  config,
  pkgs,
  microvm,
  ...
}:
{
  imports = [
    ../modules/network.nix
    ../modules/monitoring.nix
    ../modules/vm.nix

    ./hardware-configuration.nix
  ];

  nixpkgs = {
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
        experimental-features = "nix-command flakes";
        flake-registry = "";
      };
      channel.enable = false;

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      optimise = {
        automatic = true;
        dates = [ "03:45" ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  programs.nix-ld.enable = true;

  networking.hostName = "aperouge";

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
    age
    sops
    openssl
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  sops = {
    defaultSopsFile = ../secrets/caddy-ca.yaml;

    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  networking.useNetworkd = true;

  systemd.network.networks =
    builtins.listToAttrs (
      map (index: {
        name = "30-vm${toString index}";
        value = {
          matchConfig.Name = "vm${toString index}";
          # Host's addresses
          address = [
            "10.0.0.0/32"
            "fec0::/128"
          ];
          # Setup routes to the VM
          routes = [
            {
              Destination = "10.0.0.${toString index}/32";
            }
            {
              Destination = "fec0::${lib.toHexString index}/128";
            }
          ];
          # Enable routing
          networkConfig = {
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
        };
      }) (lib.genList (i: i + 1) 8)
    )
    // {
      "10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };

  networking.nat = {
    enable = true;
    internalIPs = [ "10.0.0.0/24" ];
    # Change this to the interface with upstream Internet access
    externalInterface = "enp1s0";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
