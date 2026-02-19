{ pkgs, pre-commit-check }:
{
  default = pkgs.mkShell {
    inherit (pre-commit-check) shellHook;
    buildInputs = pre-commit-check.enabledPackages;
  };

  kernel = pkgs.mkShellNoCC {
    nativeBuildInputs = with pkgs; [
      bc
      bison
      flex
      ncurses
      openssl
      elfutils
      gcc
      gnumake
      rustc
      rust-bindgen
      rustfmt
      clippy
    ];
    RUST_LIB_SRC = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  buildroot =
    let
      my-fhs = pkgs.buildFHSEnv {
        name = "my-fhs";
        targetPkgs = _: [
          pkgs.which
          pkgs.file
        ];
        runScript = "";
        profile = ''
          export MY_FHS_VAR="inside FHS env"
        '';
      };
    in
    pkgs.mkShell {
      packages = with pkgs; [
        gnumake
        binutils
        gcc
        patch
        gzip
        bzip2
        perl
        gnutar
        cpio
        unzip
        rsync
        bc
        findutils
        wget
        python3
        ncurses
        pkg-config
        git
        diffutils
        gawk
        bash
      ];

      shellHook = ''
        echo "Entering FHS environment"
        ${my-fhs}/bin/my-fhs || true
      '';
      profile = ''
        export PS1="[buildroot] $PS1"
      '';
    };
}
