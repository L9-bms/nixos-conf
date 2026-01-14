{ pkgs, ... }:

{
  fileSystems."/persist".neededForBoot = true;

  console.earlySetup = true;
  systemd.services.systemd-vconsole-setup.unitConfig.After = "local-fs.target";
  boot.initrd.systemd = {
    enable = true;
    services.initrd-rollback-root = {
      after = [ "zfs-import-rpool.service" ];
      wantedBy = [ "initrd.target" ];
      before = [
        "sysroot.mount"
      ];
      path = [ pkgs.zfs ];
      description = "Rollback root fs";
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = "zfs rollback -r rpool/nixos/root@blank";
    };
  };
  # https://notthebe.ee/blog/nixos-ephemeral-zfs-root/

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/machine-id"
    ];
    directories = [
      "/var/lib/tailscale"
      "/var/lib/nixos"
    ];
  };

  fileSystems."/var/lib/prometheus2" = {
    device = "/persist/data/prometheus2";
    options = [ "bind" ];
  };

  fileSystems."/var/lib/technitium-dns-server" = {
    device = "/persist/data/technitium-dns-server";
    options = [ "bind" ];
  };
}
