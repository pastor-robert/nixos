{
  description = "Simple Nixos flake for x1";

  inputs = {
    # Official
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # for command_not_found_handler
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-index-database, ... }@inputs: {
    nixosConfigurations.lonsdaleite = nixpkgs.lib.nixosSystem {
      modules = [
        # Import existing config so this version is a NOP
        ./configuration.nix

        # for command_not_found_handler, and nix-locate
        nix-index-database.nixosModules.default

        # wrap and install comma
        { programs.nix-index-database.comma.enable = true; }
      ];
    };
  };
}
