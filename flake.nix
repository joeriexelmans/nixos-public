{
  description = "system config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable }:
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
        deemz = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = { inherit system; };
          modules = [
            ./deemz.org/configuration.nix
          ];
        };
      };
    };
}
