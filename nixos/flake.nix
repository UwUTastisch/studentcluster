{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # Disko
    disko.url = "github:nix-community/disko";
  };

  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

  outputs = { self, nixpkgs, disko, nixos-facter-modules, ... }@inputs: let
    nodes = [
      "studentcluster-1"
      "studentcluster-2"
      "studentcluster-3"
    ];
  in {
    # Slightly experimental: Like generic, but with nixos-facter (https://github.com/numtide/nixos-facter)
    # nixos-anywhere --flake .#studentcluster-1 --generate-hardware-config nixos-facter facter.json <hostname>
    nixosConfigurations = builtins.listToAttrs (map (name: {
	    name = name;
	    value = nixpkgs.lib.nixosSystem {
     	    specialArgs = {
            meta = { hostname = name; };
          };
          system = "x86_64-linux";
          modules = [
              # Modules
	            disko.nixosModules.disko
	            ./configuration.nix
              nixos-facter-modules.nixosModules.facter
              {
                config.facter.reportPath =
                  if builtins.pathExists ./facter.json then
                    ./facter.json
                  else
                    throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
              }
          ];
        };
    }) nodes);
  };
}
