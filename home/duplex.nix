{ pkgs, duplex, ... }:
{
  # Add the script to the system-wide packages
  # environment.systemPackages = [ duplex ];

  # OR, if using home-manager, add it to user packages
  home.packages = [ duplex.packages.${pkgs.system}.default ];
}
