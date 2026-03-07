{
  config,
  inputs,
  lib,
  ...
}:

{
  imports = [ inputs.prism-tower.nixosModules.default ];

  services.technitium-dns-server.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/416320
  systemd.services.technitium-dns-server.serviceConfig = {
    WorkingDirectory = lib.mkForce null;
    BindPaths = lib.mkForce null;
    DynamicUser = lib.mkForce false;
    User = "root"; # this is probably bad
    Group = "root";
  };

  systemd.tmpfiles.rules = [
    "d /persist/data/caddy 0750 caddy caddy -"
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
      storage file_system /persist/data/caddy
      pki {
        ca 7sref_ca {
          name 7sref_ca
          root {
            cert ${config.sops.secrets."caddy/ca.pem".path}
            key ${config.sops.secrets."caddy/ca.key".path}
          }
        }
      }
      skip_install_trust
      auto_https disable_redirects
    '';
    # we are unable to install CA for all of our devices unfortunately
    virtualHosts = builtins.listToAttrs (
      map (service: {
        name = "http://${service.host}, https://${service.host}";
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
    }) (builtins.filter (service: !service.hidden) config.localServices);
  };
}
