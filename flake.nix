{
  description = "system config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # sops-nix = {
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs-stable";
    # };
    # icomidal = {
    #   url = "git+https://deemz.org/git/joeri/icomidal";
    #   inputs.nixpkgs.follows = "nixpkgs-stable";
    # };
    secrets = {
      url = "git+ssh://forgejo@deemz.org/joeri/nixos-secrets.git";
    };
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, secrets }:
    let 
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        x230 = nixpkgs-stable.lib.nixosSystem {
          specialArgs = { inherit system; };
          modules = [
            ./machines/x230/configuration.nix
          ];
        };
        deemz = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit system;

            cloudflareToken = secrets.cloudflare_api_token;
            basicAuth = secrets.nginx_userlist;

            transmissionHost = "deemz.org";
            fileserverHost = "deemz.org";
            navidromeHost = "deemz.org";
            forgejoHost = "deemz.org";
            homepageHost = "joeri-exelmans.page";

            ipv4Addr = "192.168.1.60";
            ipv4Subnet = "192.168.1.0/24";
            ipv6Addr = "2a02:578:8591:1b00::ffff";
            ipv6Subnet = "2A02:578:8591:1B00::/64";
          };
          modules = [
            ./machines/deemz/configuration.nix
          ];
        };
        msdl = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit system;
          };
          modules = [
            ./machines/msdl/configuration.nix
          ];
        };
      };
    };
}
