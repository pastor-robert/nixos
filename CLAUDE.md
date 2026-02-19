# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal NixOS configuration for a machine named "lonsdaleite" (ThinkPad X1). It uses Nix flakes with NixOS 25.11 and Home Manager.

## Commands

```bash
# Apply system configuration
sudo nixos-rebuild switch --flake .#lonsdaleite

# Apply user configuration (Home Manager)
home-manager switch --flake .#rob

# Run pre-commit checks (formatting + linting)
nix flake check

# Enter development shell (installs pre-commit hooks)
nix develop

# Update flake inputs
nix flake update
```

## Architecture

**File Structure:**
- `flake.nix` - Flake inputs (nixpkgs, home-manager, nix-index-database, git-hooks-nix) and outputs
- `configuration.nix` - System-level NixOS configuration (services, packages, users)
- `hardware-configuration.nix` - Auto-generated hardware config (do not edit manually)
- `home.nix` - User environment via Home Manager (user packages, dotfiles, programs)

**Key Design Decisions:**
- Flat structure: all config files at root level, no custom modules directory
- System packages in `configuration.nix`, user packages in `home.nix`
- Pre-commit hooks: `nixfmt-rfc-style`, `statix`, `deadnix`

**Enabled Services:**
- Desktop: KDE Plasma 6 with SDDM, WindowMaker available
- Virtualization: Incus (with preseed config for storage pools/networks), Podman (Docker-compatible)
- Networking: Tailscale, OpenSSH, NetworkManager with OpenConnect

**Adding Packages:**
- System-wide: add to `environment.systemPackages` in `configuration.nix`
- User-only: add to `home.packages` in `home.nix`
- PyPI packages: see `ffgrep` example in `home.nix` using `buildPythonApplication`
