# Machine-specific Home Manager configuration for lonsdaleite (NixOS laptop)
{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

let
  # Mount point paths
  gdriveMountDir = "/home/rob/gdrive/MyDrive";
  gdriveSharedMountDir = "/home/rob/gdrive/SharedDrives";
in
{
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    shortcut = "x";
    terminal = "tmux-256color";
    secureSocket = true;

    extraConfig = ''
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Enable mouse mode (tmux 2.1 and above)
      set -g mouse on

      # Gnome-terminal doesn't support xterm escape sequences
      # https://unix.stackexchange.com/questions/348913/copy-selection-to-a-clipboard-in-tmux
      # set-option -s set-clipboard off
      # bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
      bind-key -T copy-mode MouseDragEnd1Pane send -X copy-pipe "xclip -selection clipboard -i" \; send -X clear-selection
      bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe "xclip -selection clipboard -i" \; send -X clear-selection
    '';
  };

  home = {
    username = "rob";
    homeDirectory = "/home/rob";
    stateVersion = "25.11";

    # Environment
    sessionVariables = {
      EDITOR = "vi";
      BROWSER = "google-chrome";
      TERMINAL = "kitty";
    };

    packages = [
      # X11/GUI packages
      pkgs.xcowsay

      pkgs.htop
      pkgs.btop

      # rclone for cloud storage mounting
      pkgs.rclone
      pkgs.unzip
      pkgs.ghostty
      pkgs.marktext
      pkgs.libreoffice-qt
      pkgs.hunspell
      pkgs.hunspellDicts.en_US
      pkgs.ranger
      pkgs.atool
      pkgs.poppler-utils
      pkgs.kitty
      pkgs-unstable.antigravity-cli

      (pkgs.llm.withPlugins {
        llm-git = true;
        llm-gemini = true;
        llm-cmd = true;
      })
    ];
    shellAliases = lib.mkForce {
      x = "vi";
      ls = "ls --classify=auto --color=auto";
    };
  };

  # Create mount point directories
  home.activation.createRcloneMountPoints = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${gdriveMountDir}"
    run mkdir -p "${gdriveSharedMountDir}"
  '';

  # Systemd user services for rclone mounts
  systemd.user.services = {
    drkonqi-coredump-pickup.unitConfig.ConditionPathExists = "/var/empty";
    rclone-gdrive = {
      Unit = {
        Description = "Mount Google Drive with rclone";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "simple";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${gdriveMountDir}";
        ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: ${gdriveMountDir} --vfs-cache-mode full --vfs-cache-max-age 72h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit off --buffer-size 128M --poll-interval 15s --dir-cache-time 72h --log-level INFO";
        ExecStop = "/run/wrappers/bin/fusermount -u ${gdriveMountDir}";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    rclone-gdrive-shared = {
      Unit = {
        Description = "Mount 'Shared with me' Google Drive files with rclone";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "simple";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${gdriveSharedMountDir}";
        ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: ${gdriveSharedMountDir} --drive-shared-with-me --vfs-cache-mode full --vfs-cache-max-age 72h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit off --buffer-size 128M --poll-interval 15s --dir-cache-time 72h --log-level INFO";
        ExecStop = "/run/wrappers/bin/fusermount -u ${gdriveSharedMountDir}";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
