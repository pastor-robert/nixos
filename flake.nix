{
  description = "Multi-machine Nix flake for NixOS and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for command_not_found_handler
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nix-index-database,
      home-manager,
      git-hooks-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pre-commit-check = git-hooks-nix.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt-rfc-style.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };
      };
    in
    {
      checks.${system} = { inherit pre-commit-check; };

      nixosConfigurations.lonsdaleite = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/lonsdaleite

          # for command_not_found_handler, and nix-locate
          nix-index-database.nixosModules.default

          # wrap and install comma
          { programs.nix-index-database.comma.enable = true; }
        ];
      };

      homeConfigurations = {
        "rob@lonsdaleite" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/shared.nix
            ./home/lonsdaleite.nix
            ./home/duplex.nix
          ];
        };

        "robadams@u20-noah-1" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/shared.nix
            ./home/u20-noah-1.nix
            ./home/duplex.nix
          ];
        };
      };

      devShells.${system} = import ./shells.nix {
        inherit pkgs pre-commit-check;
      };
    };
}
