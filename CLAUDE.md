# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a multi-machine Nix configuration supporting NixOS systems and Home Manager on non-NixOS hosts. It uses Nix flakes with NixOS 25.11 and Home Manager.

**Machines:**
- **lonsdaleite**: NixOS laptop (ThinkPad X1) - full NixOS + Home Manager
- **u20-noah-1**: Ubuntu 24.04 server - Home Manager only

## Commands

```bash
# Apply NixOS system configuration (lonsdaleite only)
sudo nixos-rebuild switch --flake .#lonsdaleite

# Apply Home Manager configuration (specify machine)
home-manager switch --flake .#rob@lonsdaleite
home-manager switch --flake .#robadams@u20-noah-1

# Run pre-commit checks (formatting + linting)
nix flake check

# Enter development shell (installs pre-commit hooks)
nix develop

# Update flake inputs
nix flake update
```

## Architecture

**File Structure:**
- `flake.nix` - Flake inputs and outputs for all machines
- `hosts/` - NixOS system configurations
  - `lonsdaleite/default.nix` - System-level NixOS configuration
  - `lonsdaleite/hardware-configuration.nix` - Auto-generated hardware config (do not edit)
- `home/` - Home Manager configurations
  - `shared.nix` - Common programs/packages shared across all machines
  - `lonsdaleite.nix` - Machine-specific (username, stateVersion, GUI packages)
  - `u20-noah-1.nix` - Ubuntu server-specific config

**Key Design Decisions:**
- Hosts in `hosts/<hostname>/`, home configs in `home/`
- Shared home config (`shared.nix`) contains portable tools; machine-specific configs set username/homeDirectory/stateVersion
- System packages in host configs, user packages in home configs
- Pre-commit hooks: `nixfmt-rfc-style`, `statix`, `deadnix`

**Enabled Services (lonsdaleite):**
- Desktop: KDE Plasma 6 with SDDM, WindowMaker available
- Virtualization: Incus (with preseed config for storage pools/networks), Podman (Docker-compatible)
- Networking: Tailscale, OpenSSH, NetworkManager with OpenConnect

**Adding Packages:**
- System-wide (NixOS only): add to `environment.systemPackages` in `hosts/<hostname>/default.nix`
- User packages (all machines): add to `home.packages` in `home/shared.nix`
- Machine-specific user packages: add to `home.packages` in `home/<hostname>.nix`
- PyPI packages: see `ffgrep` example in `home/shared.nix` using `buildPythonApplication`

**Adding a New Machine:**
1. For NixOS: create `hosts/<hostname>/default.nix` and `hardware-configuration.nix`
2. Create `home/<hostname>.nix` with username, homeDirectory, stateVersion
3. Add entries to `flake.nix` in `nixosConfigurations` and/or `homeConfigurations`

## Git Configuration

This repository uses a specific SSH key for pushing to GitHub:
```bash
git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_rob -o IdentitiesOnly=yes"
```
