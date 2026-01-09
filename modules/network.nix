{ config, pkgs, ... }:

let
  localServices = {
    "grafana.7sref" =
      "${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
  };
in
{
  services.technitium-dns-server.enable = true;

  sops.secrets."caddy/ca.pem" = {
    owner = "caddy";
    group = "caddy";
    mode = "0440";
  };

  sops.secrets."caddy/ca.key" = {
    owner = "caddy";
    group = "caddy";
    mode = "0400";
  };

  services.caddy = {
    enable = true;
    user = "caddy";
    group = "caddy";
    globalConfig = ''
      pki {
        ca local {
          name 7sref_ca
          root {
            cert /run/secrets/caddy/ca.pem
            key /run/secrets/caddy/ca.key
          }
        }
      }
      skip_install_trust
    '';
    virtualHosts = builtins.mapAttrs (domain: addr: {
      extraConfig = ''
        tls {
          issuer internal {
            ca local
          }
        }
        reverse_proxy ${addr}
      '';
    }) localServices;
  };
}

# many thanks:
# https://waitwhat.sh/blog/custom_ca_caddy/
# https://m0x2a.dreamymatrix.com/caddy-as-internal-ca-and-reverse-proxy/
