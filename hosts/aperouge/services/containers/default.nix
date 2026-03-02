# can use https://beerstra.org/2024/07/12/vpn-enabled-podman-containers/

{
  imports = [
    ./media.nix
    ./ai.nix
  ];

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.backend = "podman";
}
