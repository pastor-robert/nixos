{ pkgs, instagui, ... }:
{
  home.packages = [ instagui.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
