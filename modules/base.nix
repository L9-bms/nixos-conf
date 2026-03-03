{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.modules.base;
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
{
  options.modules.base.enable = lib.mkEnableOption "Common config";

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
    i18n.defaultLocale = "en_US.UTF-8";

    console.font = "Lat2-Terminus16";

    services.openssh.enable = true;
    services.openssh.settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };

    programs.fish.enable = true;
  };
}
