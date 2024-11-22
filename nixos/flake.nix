{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, nixos-facter-modules, sops-nix, ... }@inputs:
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
          inherit inputs;
        };
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          "${inputs.self}/disko-config.nix"
          "${inputs.self}/configuration.nix"
          nixos-facter-modules.nixosModules.facter
          {
            config.facter.reportPath =
              if builtins.pathExists ./facter.json then
                ./facter.json
              else
                throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
          }
          sops-nix.nixosModules.sops
        ];
      };
    }) nodes);
  };
}
