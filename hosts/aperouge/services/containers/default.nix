# can use https://beerstra.org/2024/07/12/vpn-enabled-podman-containers/

{
  imports = [
    ./media.nix
  ];

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    forgejo = {
      image = "codeberg.org/forgejo/forgejo:11.0.9";
    };
  };
}
