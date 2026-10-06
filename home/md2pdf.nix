{ pkgs, ... }:

let
  md2pdf = pkgs.writeShellApplication {
    name = "md2pdf";
    runtimeInputs = [
      pkgs.pandoc
      pkgs.texlive.combined.scheme-full
    ];
    text = ''
      #!/bin/bash
      INPUT_MD="$1"
      OUTPUT_PDF="''${INPUT_MD%.md}.pdf"

      pandoc "$INPUT_MD" -o "$OUTPUT_PDF" \
        -V documentclass=article \
        -V fontsize=14pt \
        -V geometry="letterpaper" \
        -V geometry="margin=0.5in"
    '';
  };
in
{
  # Add the script to the system-wide packages
  # environment.systemPackages = [ foo ];

  # OR, if using home-manager, add it to user packages
  home.packages = [ md2pdf ];
}
