# Machine-specific Home Manager configuration for lonsdaleite (NixOS laptop)
{ pkgs, lib, ... }:

let
  # Mount point paths
  gdriveMountDir = "/home/rob/gdrive";
  gdriveSharedMountDir = "/home/rob/gdrive-shared";
in
{
  home = {
    username = "rob";
    homeDirectory = "/home/rob";
    stateVersion = "25.11";

    packages = [
      # X11/GUI packages
      pkgs.xcowsay

      pkgs.htop
      pkgs.btop

      # rclone for cloud storage mounting
      pkgs.rclone
      pkgs.pandoc
      pkgs.texlive.combined.scheme-full
      pkgs.unzip
    ];
    shellAliases = lib.mkForce {
      x = "vi";
    };
  };

  # Create mount point directories
  home.activation.createRcloneMountPoints = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${gdriveMountDir}"
    run mkdir -p "${gdriveSharedMountDir}"
  '';

  # Systemd user services for rclone mounts
  systemd.user.services = {
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
