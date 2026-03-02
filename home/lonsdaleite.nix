# Machine-specific Home Manager configuration for lonsdaleite (NixOS laptop)
{ pkgs, lib, ... }:

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
    ];
    shellAliases = lib.mkForce {
      x = "vi";
    };
  };
}
