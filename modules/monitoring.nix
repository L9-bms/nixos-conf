{ config, pkgs, ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.7sref";
      http_addr = "127.0.0.1";
      http_port = 2342;
    };
  };
}
