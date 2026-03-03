{
  imports = [
    ../../modules/persistence.nix
  ];

  modules.persistence = {
    enable = true;
    zfsRollback.enable = true;
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
