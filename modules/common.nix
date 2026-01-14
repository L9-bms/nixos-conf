{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.modules.common;
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
{
  options.modules.common.enable = lib.mkEnableOption "Common config for all bare metal machines";

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        flake-registry = "";
      };
      channel.enable = false;

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      optimise = {
        automatic = true;
        dates = [ "04:00" ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    time.timeZone = "Australia/Sydney";
    console.font = "Lat2-Terminus16";

    services.openssh.enable = true;
    services.openssh.settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };

    programs.fish.enable = true;
  };
}
