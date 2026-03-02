let
  pureSafeHook = ''
    export USER=''${USER:-$(id -un)}
    export HOME=''${HOME:-/home/$USER}
    export TERM=xterm
    export LANG=''${LANG:-en_US.UTF-8}
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_CACHE_HOME="$HOME/.cache"
  '';
in
{ pkgs, pre-commit-check }:
{
  default = pkgs.mkShell {
    inherit (pre-commit-check) ;
    JJ = "jj";
    HH = "$HOME";
    #packages = pre-commit-check.enabledPackages + [
    #  pkgs.vim
    #];
    shellHook = pureSafeHook + ''
      echo Welcome to the develop shell
    '';
    profile = ''
      export PS1="[develop] $PS1"
    '';
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
    shellHook = pureSafeHook + ''
      echo Welcome to the kernel shell
    '';
    profile = ''
      export PS1="[kernel] $PS1"
    '';
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

      shellHook = pureSafeHook + ''
        echo "Entering FHS environment"
        ${my-fhs}/bin/my-fhs || true
      '';
      profile = ''
        export PS1="[buildroot] $PS1"
      '';
    };
}
