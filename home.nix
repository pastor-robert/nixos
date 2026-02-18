# config,pkgs,...
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
    # doCheck = false; # Skip tests if they require extra setup
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

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "rob";
    homeDirectory = "/home/rob";

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [

      # (pkgs.python3.withPackages (_ps: [ ffgrep ]))
      ffgrep

      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      pkgs.mtr
      pkgs.charasay
      # pkgs.cowsay
      pkgs.kittysay
      pkgs.neo-cowsay
      pkgs.pokemonsay
      pkgs.ponysay
      pkgs.tewisay
      pkgs.xcowsay
      #pkgs.slack
      #pkgs.slack-term
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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    #".vimrc".text = ''
    #  " home.file.".vimrc".text
    #  filetype plugin indent on
    #  set expandtab    " Use spaces instead of tabs
    #  set tabstop=99    " Display width of tab characters
    #  set shiftwidth=4 " Number of spaces for auto-indent
    #  set softtabstop=4 " Number of spaces when you press Tab
    #  autocmd FileType c setlocal softtabstop=0 tabstop=8 noexpandtab shiftwidth=8
    #  autocmd FileType cpp setlocal softtabstop=0 tabstop=8 noexpandtab shiftwidth=8
    #  autocmd FileType bpf setlocal softtabstop=0 tabstop=8 noexpandtab shiftwidth=8
    #  '';

  };

  programs.vim.settings = {
    expandtab = true;
    tabstop = 8;
    shiftwidth = 4;
    softtabstop = 4;
  };
  #programs.vim.extraConfig = ''
  #    " programs.vim.extraConfig
  #    filetype plugin indent on
  #    set expandtab    " Use spaces instead of tabs
  #    set tabstop=99    " Display width of tab characters
  #    set shiftwidth=4 " Number of spaces for auto-indent
  #    set softtabstop=4 " Number of spaces when you press Tab
  #    #
  #    autocmd FileType c setlocal softtabstop=0 tabstop=8 noexpandtab shiftwidth=8
  #    autocmd FileType cpp setlocal softtabstop=0 tabstop=8 noexpandtab shiftwidth=8
  #    autocmd FileType bpf setlocal softtabstop=0 tabstop=8 noexpandtab shiftwidth=8
  #    '';

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/rob/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vi";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

}
