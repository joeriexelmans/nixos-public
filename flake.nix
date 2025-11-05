{
  description = "system config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    icomidal = {
      url = "git+https://deemz.org/git/joeri/icomidal";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    mtl-aas = {
      url = "git+https://deemz.org/git/teaching/mtl-aas";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, icomidal, mtl-aas }:
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
            refineryHost = "deemz.org";
            refineryBaseUrl = "/refinery";
            mtl-aas=mtl-aas.packages.${system}.default;
          };
          modules = [
            ./deemz.org/configuration.nix
            ./common/refinery.nix
            ./common/mtl-aas.nix
          ];
        };
        msdl = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit system;
            refineryHost="msdl-testing.uantwerpen.be";
            refineryBaseUrl="/refinery";
          };
          modules = [
            ./msdl/configuration.nix
            ./common/refinery.nix
          ];
        };
      };
    };
}
