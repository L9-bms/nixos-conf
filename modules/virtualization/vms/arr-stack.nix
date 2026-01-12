{ ... }:

{
  imports = [
    ./common
    ./docker-compose.nix
  ];

  networking.hostName = "arr-stack";

  vm = {
    index = 1;
    mac = "00:00:00:00:00:01";
    mem = 2000;
    diskSize = 5120;
  };

  microvm.shares = [
    {
      source = "/home/callum/changethislater/data";
      mountPoint = "/data";
      tag = "data";
      proto = "virtiofs";
    }
    {
      source = "/home/callum/changethislater/media";
      mountPoint = "/media";
      tag = "media";
      proto = "virtiofs";
    }
  ];

  # Create required directories for containers
  systemd.tmpfiles.rules = [
    "d /data/jellyfin 0755 root root -"
    "d /data/jellyfin/cache 0755 root root -"
    "d /data/jellyfin/config 0755 root root -"
    "d /data/prowlarr 0755 root root -"
    "d /data/qbittorrent 0755 root root -"
    "d /data/radarr 0755 root root -"
    "d /data/sonarr 0755 root root -"
    "d /media/media 0755 root root -"
    "d /media/torrents 0755 root root -"
  ];

  # virtualisation.podman.enable = true;
  # virtualisation.oci-containers = {
  #   backend = "podman";
  #   containers.sonarr = {
  #     image = "docker.io/linuxserver/sonarr";
  #     ports = [ "8989:8989" ];
  #   };
  # };
}

# https://bkiran.com/blog/deploying-containers-nixos
