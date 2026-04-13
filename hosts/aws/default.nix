# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot = {
    loader = {
      grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
      };
      efi.canTouchEfiVariables = false;
    };
    binfmt.emulatedSystems = [ "armv7l-linux" ];
    extraModulePackages = [ config.boot.kernelPackages.rtl8821au ];
  };

  networking = {
    hostName = "aws";

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;
    networkmanager.plugins = [ pkgs.networkmanager-openconnect ];
    extraHosts = ''
      # Tailscale network.
      # 100.70.52.120 iti-evo
      # 100.64.15.69 iti-m3
      # 100.87.82.107 iti-prec
      # 100.108.142.75 m2
      # 100.116.43.88 x1-old
      # 100.70.83.59 x1
      # 100.123.250.50 hp
      # 100.80.171.24 iti-lx2
    '';
  };
  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.rob = {
    initialPassword = "password";
    isNormalUser = true;
    description = "Rob Adams";
    extraGroups = [
      "networkmanager"
      "wheel"
      "incus-admin"
      "incus"
      "podman"
      "libvirtd"
      "kvm"
      "dialout"
    ];
    packages = with pkgs; [
      vim
      #  thunderbird
    ];
  };

  programs = {
    git = {
      enable = true;
      config.init.defaultBranch = "main";
    };

    bash.enableLsColors = false;
    # bash.shellAliases.ls = null;

    nm-applet.enable = true;

  };

  # flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      #  wget
      vim
      openconnect
      networkmanager-openconnect
      # ghostty
    ];
    pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
    shellAliases = {
      l = null;
      ll = null;
      ls = null;
      lsl = null;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
