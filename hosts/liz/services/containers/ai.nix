{
  pkgs,
  lib,
  ...
}:

{
  virtualisation.oci-containers.containers = {
    "ai-searxng" = {
      image = "searxng/searxng:latest";
      volumes = [ "/persist/data/searxng:/etc/searxng:rw" ];
      extraOptions = [
        "--network=ai"
        "--ip=172.22.0.3"
        "--cap-drop=ALL"
        "--cap-add=CHOWN"
        "--cap-add=SETGID"
        "--cap-add=SETUID"
        "--cap-add=DAC_OVERRIDE"
      ];
    };
    "ai-openwebui" = {
      image = "ghcr.io/open-webui/open-webui:main-slim";
      ports = [ "8088:8080" ];
      environment = {
        "ENABLE_RAG_WEB_SEARCH" = "True";
        "RAG_WEB_SEARCH_ENGINE" = "searxng";
        "RAG_WEB_SEARCH_RESULT_COUNT" = "3";
        "RAG_WEB_SEARCH_CONCURRENT_REQUESTS" = "10";
        "SEARXNG_QUERY_URL" = "http://172.22.0.3:8080/search?q=<query>";
      };
      volumes = [
        "/persist/data/open-webui:/app/backend/data"
      ];
      extraOptions = [
        "--network=ai"
        "--ip=172.22.0.2"
      ];
    };
    # "ai-copilot-api" = {
    #   image = "copilot-api:latest";
    #   ports = [ "4141:4141" ];
    #   volumes = [
    #     "/persist/data/copilot-data:/root/.local/share/copilot-api"
    #   ];
    #   extraOptions = [
    #     "--network=ai"
    #     "--ip=172.22.0.4"
    #   ];
    # };
  };

  systemd.services =
    let
      containers = [
        "ai-searxng"
        "ai-openwebui"
        # "ai-copilot-api"
      ];
    in
    lib.foldl' (
      acc: name:
      acc
      // {
        "podman-${name}" = {
          serviceConfig = {
            Restart = lib.mkOverride 90 "always";
          };
          after = [ "podman-network-ai.service" ];
          requires = [ "podman-network-ai.service" ];
          partOf = [ "podman-compose-ai-root.target" ];
          wantedBy = [ "podman-compose-ai-root.target" ];
        };
      }
    ) { } containers
    // {
      "podman-network-ai" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "podman network rm -f ai";
        };
        script = ''
          podman network inspect ai || podman network create ai --subnet=172.22.0.0/16 --disable-dns
        '';
        partOf = [ "podman-compose-ai-root.target" ];
        wantedBy = [ "podman-compose-ai-root.target" ];
      };
    };

  systemd.targets."podman-compose-ai-root" = {
    wantedBy = [ "multi-user.target" ];
  };
}
