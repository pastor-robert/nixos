# Shared Home Manager configuration - portable across machines
{ pkgs, ... }:

let
  # Define the custom package from PyPI
  ffgrep = pkgs.python3Packages.buildPythonApplication rec {
    pname = "ffgrep";
    version = "1.1.0";
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      # You must provide the correct hash for security/reproducibility
      sha256 = "sha256-gYohWiVUng0b4BXA2W9BtBLGMgrO13SboPc99JsRipY=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    propagatedBuildInputs = [ ];
    pyproject = true;
  };
in
{
  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    gh = {
      enable = true;
      settings = {
        version = "1";
        aliases = {
          "as" = "auth status";
        };
        movie = "film";
      };
      gitCredentialHelper.enable = true;
      extensions = [ pkgs.gh-eco ];
    };
    bash.enable = true;
  };

  home = {
    packages = [
      ffgrep

      pkgs.mtr
      pkgs.charasay
      pkgs.kittysay
      pkgs.neo-cowsay
      pkgs.pokemonsay
      pkgs.ponysay
      pkgs.tewisay
      pkgs.file
      pkgs.pdftk
    ];
    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Rob Adams";
      user.email = "rob@rob-adams.us";
    };
  };

  home.file = {
    # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.vim.settings = {
    expandtab = true;
    tabstop = 8;
    shiftwidth = 4;
    softtabstop = 4;
  };

  home.sessionVariables = {
    EDITOR = "vi";
  };
}
