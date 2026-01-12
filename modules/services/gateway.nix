{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.modules.services.gateway;
in
{
  imports = [ inputs.prism-tower.nixosModules.default ];

  options.modules.services.gateway.enable =
    lib.mkEnableOption "Technitium DNS, Caddy reverse proxy, dashboard";

  config = lib.mkIf cfg.enable {
    services.technitium-dns-server.enable = true;

    systemd.tmpfiles.rules = [
      "d /persist/caddy 0750 caddy caddy -"
    ];

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
        storage file_system /persist/caddy
        pki {
          ca 7sref_ca {
            name 7sref_ca
            root {
              cert ${config.sops."caddy/ca.pem".path}
              key ${config.sops."caddy/ca.key".path}
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
        }) config.localServices
      );
    };

    services.prism-tower = {
      enable = true;
      services = map (service: {
        name = service.name;
        url = "https://${service.host}";
        iconUrl = service.iconUrl;
        category = service.category;
      }) config.localServices;
    };
  };
}

# many thanks:
# https://waitwhat.sh/blog/custom_ca_caddy/
# https://m0x2a.dreamymatrix.com/caddy-as-internal-ca-and-reverse-proxy/
# https://zackmyers.io/blog/deploy-astro-on-nixos/
