{ config, cloudflareToken, ... }:
let
  deemz = {
    zone_id = "5db5e28fdb4abbc3f55cf2fcab6770c1";
    dns_record_id = "78960756f79d9bb8188b93d377bac78c";
  };
  homepage = {
    zone_id = "0c8f9fe749055f83f52d69e64d7c1455";
    dns_record_id = "f3a93566b22f94a11254eeba6b8ad602";
  };
in {
  users.users.cloudflare-dns = {
    isSystemUser = true;
    group = "dyndns";
  };
  users.groups.dyndns = {}; # create this user

  systemd.timers.cloudflare-dns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:*:00"; # every minute
      Persistent = true;
      Unit = "cloudflare-dns.service";
    };
  };
  systemd.services.cloudflare-dns = let
    cloudflare = import ./cloudflare.nix;
    command = cfg: ''
      ${pkgs.curl}/bin/curl \
        --request PUT \
        --url https://api.cloudflare.com/client/v4/zones/${cfg.zone_id}/dns_records/${cfg.dns_record_id} \
        --header 'Content-Type: application/json' \
        --header 'Authorization: Bearer ''\'''${TOKEN}''' \
        --data '{
           "comment": "Domain verification record",
           "name": "@",
           "proxied": false,
           "settings": {},
           "tags": [],
           "ttl": 60,
           "content": "''\'''${IP}'",
           "type": "A"
        }'
    '';
  in {
    script = ''
      echo "updating cloudflare DNS ..."
      TOKEN="${cloudflareToken}"
      IP="$(${pkgs.curl}/bin/curl https://ipinfo.io/ip)"
      echo "''${TOKEN} ''${IP}"
      ${command homepage}
      ${command deemz}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "cloudflare-dns";
    };
  };
}
