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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDbohv1UoLyc7mfaho1z/JDe14DH4sDj+rc6vLr4d1HZ4J6LKsR9r7o3ZIsw2AIvT0g3VOCjWxVv2JoFkbUS07HE9i/gVp8R+/Z3zZsNhX7jEL+CUaqTgjqKp1QUHMDA1+Y5F7gxshVfk1HyZmrnKbJarux3r2NA+rVj4c7Fm7wh8J/irGUzicJO94vU9ASYc6RLWEJZNuwLxEOFJ9VrfhFAp+ERZvBvLiWk6Gr2B8r5jw056t2rhcQETgyQH79i92c18Vy0L33NZ/ltPGybRKqnZS9vpLjtIPsHA7iJT/9b8CLwlEm/Esg5sUthzCdNDXo48mtxdoq99Fcor450+VxLm6NnM18SBKx/mv+CKcob69Yzr10A1948mNs6Yjj3v4zbIlOv9egv3c2Wxr56DoZxOWSB0CF4PYn2pYvIrs20czRRoz6wuCevqXDb9aCq05L/yyJGpMjVy6fp1BCDeeKblvxaZDwPXqtwsNhkpS7m5KHDxGwSr6UjIaQlbMS7/k= callum@CallumPC"
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
