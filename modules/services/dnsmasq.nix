{ config, ipv4Addr, ipv6Addr, ... }:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1" # Cloudflare primary
        "1.0.0.1" # Cloudflare secondary
        "8.8.8.8" # Google primary
        "8.8.4.4" # Google secondary
        "2606:4700:4700::1111" # Cloudflare primary
        "2606:4700:4700::1001" # Cloudflare secondary
        "2a02:578:8000:2:212:71:0:33" # Edpnet primary
        "2a02:578:1001:3:212:71:8:10" # Edpnet secondary
      ];
      listen-address = "::1,${ipv6Addr},127.0.0.1,${ipv4Addr}";
      cache-size = 10000;
    };
  };
}
