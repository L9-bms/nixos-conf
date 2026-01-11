{ config, lib, ... }:

let
  cfg = config.modules.services.monitoring;
in
{
  options.modules.services.monitoring.enable = lib.mkEnableOption "Grafana + Prometheus (for now)";

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings.server = {
        domain = "grafana.7sref";
        http_addr = "127.0.0.1";
        http_port = 2342;
      };
    };

    services.prometheus = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9001;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };
      scrapeConfigs = [
        {
          job_name = "local_node";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
      ];
    };
  };
}
