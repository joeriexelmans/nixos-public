{ config, pkgs, ... }:
{  
  # Make certificate file globally available
  # Then just add the connection 'eduroam' through NetworkManager (wpa_supplicant) with this file.
  # (I cannot point NetworkManager to the same file in my home directory -- it cannot access it)
  #
  # Furthermore, the CA ROOT included in the certificate file from Pintra is wrong.
  # I had to replace it with this one: https://repo.harica.gr/certs/HARICA-TLS-Root-2021-RSA.pem
  environment.etc."ssl/certs/eduroam_chain.pem".source = ../../assets/certs/eduroam_chain.pem;
}
