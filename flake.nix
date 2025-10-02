{
  description = "system config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    icomidal = {
      url = "git+https://deemz.org/git/joeri/icomidal";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, icomidal }:
    let 
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        t14 = nixpkgs-stable.lib.nixosSystem {
          specialArgs = { inherit system; };
          modules = [
            ./t14/configuration.nix
          ];
        };
        deemz = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit system;
            icomidal=icomidal.packages.${system}.default;
            host = "deemz.org";
            baseUrl = "/refinery";
          };
          modules = [
            ./deemz.org/configuration.nix
            ./deemz.org/refinery.nix
          ];
        };
        msdl = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit system;
            host="msdl-testing.uantwerpen.be";
            baseUrl="/refinery";
          };
          modules = [
            ./msdl/configuration.nix
            ./deemz.org/refinery.nix
          ];
        };
      };
    };
}
