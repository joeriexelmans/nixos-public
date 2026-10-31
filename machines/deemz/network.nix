{ config, ipv4Addr, ipv6Addr, ipv4Mask, ipv6Mask ... }:
{
  networking.hostName = "seedbox"; # Define your hostname.
  networking.domain = "deemz.org";
  networking.fqdn = "deemz.org";
  networking.useDHCP = false;
  networking.interfaces.enp1s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = ${ipv4Addr};
        prefixLength = 24;
      }
    ];
    ipv6.addresses = [
      {
        # address = "2a02:578:8591:1b00::ffff";
        address = ${ipv6Addr};
        prefixLength = 64;
      }
    ];
  };
  networking.enableIPv6 = true;
  networking.defaultGateway = "192.168.1.1";
  #networking.defaultGateway6 = {
  #  address = "fe80::52d4:f7ff:fe28:9849"; # TP-Link router
  #  interface = "enp1s0";
  #};
  networking.nameservers = [ "1.1.1.1" ];
  networking.extraHosts = ''
    192.168.1.60             mstro.duckdns.org
    192.168.1.60             deemz.org
    192.168.1.60             joeri-exelmans.page
  '';
    # 2a02:578:8591:1b00::ffff mstro.duckdns.org
  networking.networkmanager.unmanaged = [ "enp1s0" ];

  # IPv6 is enabled, meaning we're not protected by NAT -> enable firewall
  networking.firewall = {
    enable = true;
    
    # Accept all traffic from local network:
    extraCommands = ''
      # iptables -A nixos-fw -p tcp --source 192.168.1.0/24 -j nixos-fw-accept
      # iptables -A nixos-fw -p udp --source 192.168.1.0/24 -j nixos-fw-accept
      # ip6tables -A nixos-fw -p tcp --source 2A02:578:8591:1B00::/64 -j nixos-fw-accept
      # ip6tables -A nixos-fw -p udp --source 2A02:578:8591:1B00::/64 -j nixos-fw-accept

      iptables -A nixos-fw -p tcp --source ${ipv4Mask} -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source ${ipv4Mask} -j nixos-fw-accept
      ip6tables -A nixos-fw -p tcp --source ${ipv6Mask} -j nixos-fw-accept
      ip6tables -A nixos-fw -p udp --source ${ipv6Mask} -j nixos-fw-accept
    '';
  };
}
