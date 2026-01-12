{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale.enable = lib.mkEnableOption "Tailscale auth key setup";

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    sops.secrets."tailscale/auth-key" = { };

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      after = [ "network-pre.target" "tailscaled.service" ];
      wants = [ "network-pre.target" "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";

      script = ''
          # wait for tailscaled to settle
          sleep 2

          # check if we are already authenticated to tailscale
          status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
          if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
          fi

          # otherwise authenticate with tailscale
          ${pkgs.tailscale}/bin/tailscale up --auth-key=${config.sops.secrets."tailscale/auth-key".path}
      '';
    };
  };
}