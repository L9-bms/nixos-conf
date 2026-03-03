{ pkgs, ... }:

let
  sharesConfig = {
    tank_colin = "/tank/colin";
    callum = "/tank/callum";
    photo = "/tank/photo";
    media = "/mnt/media";
    torrents = "/tank/torrents";
  };
in
{
  services.samba = {
    package = pkgs.samba4Full;
    enable = true;
    openFirewall = true;

    # do not forget: $ sudo smbpasswd -a username

    settings =
      let
        shares = builtins.mapAttrs (name: path: {
          path = path;
          browseable = true;
          "read only" = false;
          "guest ok" = false;
        }) sharesConfig;
      in
      {
        global = { };
      }
      // shares;
  };

  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
