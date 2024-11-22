{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-facter-modules
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    # No need to override inputs for nixos-facter-modules
  };

  outputs = { self, nixpkgs, disko, nixos-facter-modules, ... }@inputs:
  let
    nodes = [
      "studentcluster-1"
      "studentcluster-2"
      "studentcluster-3"
    ];
  in {
    nixosConfigurations = builtins.listToAttrs (map (name: {
      name = name;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          meta = { hostname = name; };
        };
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          "${inputs.self}/disko-config.nix"
          "${inputs.self}/keys.nix"
          "${inputs.self}/configuration.nix"
          nixos-facter-modules.nixosModules.facter
          {
            config.facter.reportPath =
              if builtins.pathExists "${inputs.self}/facter.json" then
                "${inputs.self}/facter.json"
              else
                throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
          }
        ];
      };
    }) nodes);
  };
}
