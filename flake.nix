{
  description = "Simple Nixos flake for x1";

  inputs = {
    # Official
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.lonsdaleite = nixpkgs.lib.nixosSystem {
      modules = [
        # Import existing config so this version is a NOP
        ./configuration.nix
      ];
    };
  };
}
