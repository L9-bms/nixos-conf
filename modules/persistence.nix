{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.persistence;
in
{
  options.modules.persistence = {
    enable = lib.mkEnableOption "Impermanence";

    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional directories to persist in /persist";
    };

    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional files to persist in /persist";
    };

    zfsRollback = {
      enable = lib.mkEnableOption "Rollback root filesystem on every boot with zfs";

      pool = lib.mkOption {
        type = lib.types.str;
        default = "rpool";
        description = "ZFS pool name for rollback";
      };

      dataset = lib.mkOption {
        type = lib.types.str;
        default = "nixos/root";
        description = "ZFS root dataset to rollback";
      };

      snapshot = lib.mkOption {
        type = lib.types.str;
        default = "blank";
        description = "ZFS snapshot to rollback to";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems."/persist".neededForBoot = true;

    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;

      directories = lib.flatten [
        "/var/lib/nixos" # persist uids/gids
        "/var/lib/samba" # passwords
        "/var/log"
        (lib.optional config.services.tailscale.enable "/var/lib/tailscale")
        cfg.directories
      ];

      files = lib.flatten [
        "/etc/machine-id" # important!!!
        (lib.concatMap (key: [
          key.path
          "${key.path}.pub"
        ]) config.services.openssh.hostKeys)
        cfg.files
      ];
    };

    console.earlySetup = lib.mkIf cfg.zfsRollback.enable true;
    systemd.services.systemd-vconsole-setup.unitConfig.After =
      lib.mkIf cfg.zfsRollback.enable "local-fs.target";

    boot.initrd.systemd = lib.mkIf cfg.zfsRollback.enable {
      enable = true;
      services.initrd-rollback-root = {
        after = [ "zfs-import-${cfg.zfsRollback.pool}.service" ];
        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        path = [ pkgs.zfs ];
        description = "Rollback root fs";
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = "zfs rollback -r ${cfg.zfsRollback.pool}/${cfg.zfsRollback.dataset}@${cfg.zfsRollback.snapshot}";
      };
    };
  };
}
