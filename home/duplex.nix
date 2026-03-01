# In /etc/nixos/configuration.nix or home.nix
{ pkgs, ... }:

let
  duplex = pkgs.writeShellScriptBin "duplex" ''
    #!/bin/sh

    set -ex 

    infile=''${1-"-"}
    shift

    # Define the cleanup function
    cleanup() {
        echo "Caught signal, cleaning up..."
        # Remove the entire temporary directory recursively and forcefully
        rm -f "$full" "$even" "$odd"
        echo "Done cleaning up."
    }


    # Set the trap: call the cleanup function on these signals
    trap cleanup EXIT      # runs on normal script exit
    trap cleanup SIGINT    # runs on Ctrl+C (Interrupt)
    trap cleanup SIGTERM   # runs when a process is killed (e.g., `kill <PID>`)
    trap cleanup SIGHUP    # runs when a terminal is closed

    full=$(mktemp --suffix .pdf)
    even=$(mktemp --suffix .pdf)
    odd=$(mktemp --suffix .pdf)

    ${pkgs.pdftk}/bin/pdftk A="$infile" cat A output "$full"
    pdftk A="$full" cat Aeven output "$even"
    pdftk A="$full" cat Aodd output "$odd"

    P=Hewlett-Packard_HP_Color_LaserJet_M553

    echo First we print the even pages from Tray 2
    # lpr -P HP-Color-LaserJet-M553 -o page-set=even -o collate=true "$@"
    # psselect -e "$@" | lpr -P "$P" -o collate=true -# 2
    ${pkgs.cups}/bin/lpr -P "$P" "$@" "$even"
    # xdg-open "$even"

    echo Now flip the pages into Tray 1, with the printed side up.
    echo press enter when ready
    read i

    #lpr -P HP-Color-LaserJet-M553 -o page-set=odd -o collate=true "$@"
    # psselect -o "$@" | lpr -P "$P" -o collate=true -# 2
    lpr -P "$P" "$@" "$odd"
  '';
in
{
  # Add the script to the system-wide packages
  # environment.systemPackages = [ duplex ];

  # OR, if using home-manager, add it to user packages
  home.packages = [ duplex ];
}
