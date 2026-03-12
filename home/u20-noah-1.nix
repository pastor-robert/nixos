# Machine-specific Home Manager configuration for u20-noah-1 (Ubuntu 24.04 server)
{ pkgs, ... }:

{
  home = {
    username = "robadams";
    homeDirectory = "/home/robadams";
    stateVersion = "25.11";

    packages = [
      # X11 for ssh -X forwarding
      pkgs.xcowsay
      pkgs.htop
    ];
  };
}
