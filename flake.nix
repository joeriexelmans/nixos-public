{
  description = "system config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    icomidal = {
      url = "git+https://deemz.org/git/joeri/icomidal";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, sops-nix, icomidal }:
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
            #refineryHost = "deemz.org";
            #refineryBaseUrl = "/refinery";
            sops-nix = sops-nix;
          };
          modules = [
            ./deemz.org/configuration.nix
            #./common/refinery.nix
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
