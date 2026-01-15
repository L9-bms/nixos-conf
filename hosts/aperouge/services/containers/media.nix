{
  pkgs,
  lib,
  config,
  ...
}:

{
  virtualisation.oci-containers.containers = {
    "media-flaresolverr" = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = {
        "CAPTCHA_SOLVER" = "none";
        "LOG_HTML" = "false";
        "LOG_LEVEL" = "info";
        "TZ" = "Australia/Sydney";
      };
      extraOptions = [
        "--network-alias=flaresolverr"
        "--network=media"
        "--ip=172.16.0.6"
      ];
    };
    "media-jellyfin" = {
      image = "jellyfin/jellyfin";
      environment = {
        "JELLYFIN_PublishedServerUrl" = "https://jellyfin.7sref";
      };
      volumes = [
        "/mnt/media/media:/media:rw"
        "/persist/data/media/jellyfin/cache:/cache:rw"
        "/persist/data/media/jellyfin/config:/config:rw"
      ];
      extraOptions = [
        "--network-alias=jellyfin"
        "--network=media"
        "--ip=172.16.0.7"
      ];
    };
    "media-prowlarr" = {
      image = "ghcr.io/hotio/prowlarr";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = "Sydney/Australia";
      };
      volumes = [
        "/persist/data/prowlarr:/config:rw"
      ];
      extraOptions = [
        "--ip=172.21.0.5"
        "--network-alias=prowlarr"
        "--network=media"
      ];
    };
    "media-qbittorrent" = {
      image = "ghcr.io/hotio/qbittorrent:latest";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = "Sydney/Australia";
        "WEBUI_PORTS" = "11090/tcp";
      };
      volumes = [
        "/mnt/media/torrents:/data/torrents:rw"
        "/persist/data/media/qbittorrent:/config:rw"
      ];
      extraOptions = [
        "--ip=172.21.0.2"
        "--network-alias=qbittorrent"
        "--network=media"
      ];
    };
    "media-radarr" = {
      image = "ghcr.io/hotio/radarr:latest";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = "Sydney/Australia";
      };
      volumes = [
        "/mnt/media:/data:rw"
        "/persist/data/media/radarr:/config:rw"
      ];
      extraOptions = [
        "--ip=172.21.0.4"
        "--network-alias=radarr"
        "--network=media"
      ];
    };
    "media-sonarr" = {
      image = "ghcr.io/hotio/sonarr:latest";
      environment = {
        "PGID" = "1000";
        "PUID" = "1000";
        "TZ" = "Sydney/Australia";
      };
      volumes = [
        "/mnt/media:/data:rw"
        "/persist/data/media/sonarr:/config:rw"
      ];
      extraOptions = [
        "--ip=172.21.0.3"
        "--network-alias=sonarr"
        "--network=media"
      ];
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
            after = [ "podman-network-media.service" ];
            requires = [ "podman-network-media.service" ];
            partOf = [ "podman-compose-media-root.service" ];
            wantedBy = [ "podman-compose-media-root.service" ];
          };
        })
        [
          "podman-media-sonarr"
          "podman-media-radarr"
          "podman-media-prowlarr"
          "podman-media-flaresolverr"
          "podman-media-qbittorrent"
          "podman-media-jellyfin"
        ]
    ))
    {
      "podman-network-media" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "podman network rm -f media";
        };
        script = ''
          podman network inspect media || podman network create media --subnet=172.21.0.0/16
        '';
        partOf = [ "podman-compose-media-root.target" ];
        wantedBy = [ "podman-compose-media-root.target" ];
      };
    }
  ];

  systemd.targets."podman-compose-media-root" = {
    wantedBy = [ "multi-user.target" ];
  };
}
