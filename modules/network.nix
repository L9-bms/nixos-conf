{
  inputs,
  config,
  ...
}:

let
  localServices = [
    {
      name = "Grafana";
      host = "grafana.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/grafana.png";
      addr = "${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
    }
    {
      name = "Prometheus";
      host = "prometheus.7sref";
      iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/prometheus.png";
      addr = "${toString config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
    }
  ];
in
{
  imports = [ inputs.prism-tower.nixosModules.default ];

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
        ca 7sref_ca {
          name 7sref_ca
          root {
            cert /run/secrets/caddy/ca.pem
            key /run/secrets/caddy/ca.key
          }
        }
      }
      skip_install_trust
    '';
    virtualHosts = builtins.listToAttrs (
      map (service: {
        name = service.host;
        value = {
          extraConfig = ''
            tls {
              issuer internal {
                ca 7sref_ca
              }
            }
            reverse_proxy ${service.addr}
          '';
        };
      }) localServices
    );
  };

  services.prism-tower = {
    enable = true;
    services = map (service: {
      name = service.name;
      url = "https://${service.host}";
      iconUrl = service.iconUrl;
    }) localServices;
  };
}

# many thanks:
# https://waitwhat.sh/blog/custom_ca_caddy/
# https://m0x2a.dreamymatrix.com/caddy-as-internal-ca-and-reverse-proxy/
# https://zackmyers.io/blog/deploy-astro-on-nixos/
