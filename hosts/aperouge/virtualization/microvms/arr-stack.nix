{ ... }:

{
  imports = [
    ./common.nix
    ./docker-compose.nix
  ];

  networking.hostName = "arr-stack";

  vm = {
    index = 1;
    mac = "00:00:00:00:00:01";
    mem = 2000;
  };

  microvm.volumes = [
    {
      image = "/dev/zvol/rpool/vms/arr-stack";
      mountPoint = "/";
      size = 10240;
    }
  ];

  microvm.shares = [
    {
      source = "/persist/data/arr-stack";
      mountPoint = "/data";
      tag = "data";
      proto = "virtiofs";
    }
    {
      source = "/mnt/media";
      mountPoint = "/media";
      tag = "media";
      proto = "virtiofs";
    }
  ];

  systemd.tmpfiles.rules = [
    "d /data/sonarr 0755 root root -"
    "d /data/radarr 0755 root root -"
    "d /data/prowlarr 0755 root root -"
    "d /data/qbittorrent 0755 root root -"
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
