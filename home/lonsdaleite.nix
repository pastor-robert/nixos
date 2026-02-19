# Machine-specific Home Manager configuration for lonsdaleite (NixOS laptop)
{ pkgs, ... }:

{
  home = {
    username = "rob";
    homeDirectory = "/home/rob";
    stateVersion = "25.11";

    packages = [
      # X11/GUI packages
      pkgs.xcowsay
    ];
  };
}
