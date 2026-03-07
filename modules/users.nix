{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.users;
in
{
  options.modules.users.enable = lib.mkEnableOption "Users";

  config = lib.mkIf cfg.enable {
    users.users.callum = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMP4bm4SjbUcveDfeNVU7QkWz/pFWuVrPsZIa5e6ZE64 callum@acid"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINw8zK93i7WJYfbmpcXE5ZYTWRvkm3ohIdsvWmWOkCFQ callum@wky"
      ];
      shell = if config.programs.fish.enable then pkgs.fish else pkgs.bash;
      extraGroups = lib.flatten [
        "wheel"
        (lib.optional config.virtualisation.libvirtd.enable "libvirtd")
        (lib.optional config.networking.networkmanager.enable "networkmanager")
      ];
    };
  };
}
