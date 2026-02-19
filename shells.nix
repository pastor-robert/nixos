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
    (pkgs.buildFHSEnv {
      name = "buildroot-fhs";
      targetPkgs =
        pkgs: with pkgs; [
          file
          which
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
      runScript = "bash";
      profile = ''
        export PS1="[buildroot] $PS1"
      '';
    }).env;
}
