# Example configuration:
#  host: deemz.org
#  refineryBaseUrl: /refinery

{ config, pkgs, refineryHost, refineryBaseUrl, ... }:
{
  # reverse proxy
  services.nginx = {
    enable = true;

    virtualHosts.${refineryHost} = {

      locations."${refineryBaseUrl}/" = {
        proxyPass = "http://127.0.0.1:8888/";
        proxyWebsockets = true;
      };

      locations."${refineryBaseUrl}/api/" = {
        proxyPass = "http://127.0.0.1:8888/api/";
        extraConfig = ''
          chunked_transfer_encoding off;
          proxy_buffering off;
          proxy_cache off;
        '';
      };

      serverName = refineryHost;
    };
  };

  # run refinery container as a systemd service
  virtualisation.oci-containers.containers = {
    refinery = {
      image = "ghcr.io/graphs4value/refinery:0.2.1-snapshot";
      ports = [ "127.0.0.1:8888:8888" ];
      environment = rec {
        REFINERY_PUBLIC_HOST = refineryHost;
        REFINERY_WEBSOCKET_URL = "wss://${refineryHost}${refineryBaseUrl}/xtext-service";
        REFINERY_API_BASE = "https://${refineryHost}${refineryBaseUrl}/api/v1/";

        # Timeouts
        REFINERY_MODEL_GENERATION_TIMEOUT_SEC = "60";
        REFINERY_MODEL_GENERATION_THREAD_COUNT = "10";
      };
    };
  };
}
