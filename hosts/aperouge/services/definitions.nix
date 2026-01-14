{ config, lib, ... }:

{
  options.localServices = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Dashboard display name";
          };
          host = lib.mkOption {
            type = lib.types.str;
            description = "Hostname";
          };
          addr = lib.mkOption {
            type = lib.types.str;
            description = "Backend address";
          };
          iconUrl = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Dashboard icon URL";
          };
          category = lib.mkOption {
            type = lib.types.str;
            default = "Other";
            description = "Dashboard category";
          };
        };
      }
    );
    default = [ ];
    description = "Service metadata for reverse proxy and dashboard";
  };

  config.localServices = [
    {
      name = "Grafana";
      host = "grafana.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/grafana.png";
      addr = "${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      category = "Monitoring";
    }
    {
      name = "Prometheus";
      host = "prometheus.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/prometheus.png";
      addr = "${toString config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
      category = "Monitoring";
    }

    {
      name = "Sonarr";
      host = "sonarr.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/sonarr.png";
      addr = "10.0.0.1:8989";
      category = "Media";
    }
    {
      name = "Radarr";
      host = "radarr.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/radarr.png";
      addr = "10.0.0.1:7878";
      category = "Media";
    }
    {
      name = "Prowlarr";
      host = "prowlarr.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/prowlarr.png";
      addr = "10.0.0.1:9696";
      category = "Media";
    }
    {
      name = "qBittorrent";
      host = "qbittorrent.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/qbittorrent.png";
      addr = "10.0.0.1:11090";
      category = "Media";
    }
    # {
    #   name = "Jellyfin";
    #   host = "jellyfin.7sref";
    #   iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jellyfin.png";
    #   addr = "10.0.0.1:8096";
    #   category = "Media";
    # }
    {
      name = "FlareSolverr";
      host = "flaresolverr.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/flaresolverr.png";
      addr = "10.0.0.1:8191";
      category = "Media";
    }
  ];
}
