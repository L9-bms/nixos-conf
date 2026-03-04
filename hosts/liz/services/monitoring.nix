{ config, ... }:

{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.7sref";
      http_addr = "127.0.0.1";
      http_port = 2342;
    };
    dataDir = "/persist/data/grafana";
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "logind"
          "processes"
          "systemd"
          "tcpstat"
        ];
        port = 9002;
      };
      smartctl = {
        enable = true;
        port = 9003;
      };
      zfs = {
        enable = true;
        port = 9004;
      };
    };
    scrapeConfigs =
      map
        (exporter: {
          job_name = "local_${exporter}";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.${exporter}.port}" ];
            }
          ];
        })
        [
          "node"
          "smartctl"
          "zfs"
        ];
  };
}
