{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./common.nix
  ];

  networking.hostName = "dmz";

  vm = {
    index = 1;
    mac = "00:00:00:00:00:01";
    mem = 2000;
  };

  microvm.volumes = [
    {
      image = "/dev/zvol/rpool/vms/dmz";
      mountPoint = "/";
      size = 10240;
    }
  ];

  # Enable container name DNS for all Podman networks.
  networking.firewall.interfaces =
    let
      matchAll = "podman+";
    in
    {
      "${matchAll}".allowedUDPPorts = [ 53 ];
    };

  services.caddy = {
    enable = true;
    user = "caddy";
    group = "caddy";
    virtualHosts = {
      "maimai-wiki.callumwong.com" = {
        extraConfig = ''
          reverse_proxy hi
        '';
      };
    };
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    mediawiki = {
      image = "docker.io/mediawiki:latest";
      ports = [ "8080:80/tcp" ];
      environment = {
        MEDIAWIKI_DB_HOST = "db";
        MEDIAWIKI_DB_USER = "mediawiki";
        MEDIAWIKI_DB_PASSWORD = "KYo7nweCgET7u";
        MEDIAWIKI_DB_NAME = "mediawiki";
      };
      dependsOn = [ "mediawiki-db" ];
      volumes = [
        "/persist/data/mediawiki/images:/var/www/html/images"
        "/persist/data/mediawiki/assets:/var/www/html/assets"
        "/persist/data/mediawiki/LocalSettings.php:/var/www/html/LocalSettings.php"
      ];
    };
    mediawiki-db = {
      image = "mysql:5.7";
      environment = {
        MYSQL_ROOT_PASSWORD = "hKYo7nweCgET7u";
        MYSQL_DATABASE = "mediawiki";
        MYSQL_USER = "mediawiki";
        MYSQL_PASSWORD = "hKYo7nweCgET7u";
      };
    };
  };

  systemd.services = lib.mergeAttrsList [
    (lib.mergeAttrsList (
      map
        (name: {
          ${name} = {
            serviceConfig = {
              Restart = lib.mkOverride 90 "always";
            };
            after = [ "podman-network-wiki.service" ];
            requires = [ "podman-network-wiki.service" ];
          };
        })
        [
          "podman-mediawiki"
          "podman-mediawiki-db"
        ]
    ))
    {
      "podman-network-wiki" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "podman network rm -f wiki";
        };
        script = ''
          podman network inspect wiki || podman network create wiki
        '';
      };
    }
  ];
}

# https://bkiran.com/blog/deploying-containers-nixos
