# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit=20;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lonsdaleite";

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];
  services.openssh.enable = true;
  services.tailscale.enable = true; 

  networking.extraHosts = ''
    # Tailscale network.
    100.70.52.120 iti-evo
    100.64.15.69 iti-m3
    100.87.82.107 iti-prec
    100.108.142.75 m2
    100.116.43.88 x1-old
    100.70.83.59 x1
    100.123.250.50 hp
    '';

  # Incus
  networking.firewall.trustedInterfaces = [ "incusbr0" ];
  networking.nftables.enable = true;
  virtualisation.incus.enable = true;
  virtualisation.incus.ui.enable = true;
  virtualisation.incus.package = pkgs.incus;
  virtualisation.incus.preseed = {
    config = {
      "core.https_address" = ":8443";
    };
    networks = [
      {
        config = {
          "ipv4.address" = "auto";
          "ipv6.address" = "auto";
        };
        "name" = "incusbr0";
        "type" = "";
      }
    ];
    storage_pools = [
      {
        config = {
          "source" = "/home/incus/storage-pools/home";
        };
        "description" = "";
        "name" = "home";
        "driver" = "dir";
      }
      {
        config = {
          "source" = "/data/incus/storage-pools/home";
        };
        "description" = "";
        "name" = "data";
        "driver" = "dir";
      }
    ];
    storage_volumes = [];
    profiles = [
      {
        description = "";
        devices = {
          eth0 = {
            "name" = "eth0";
            "network" = "incusbr0";
            "type" = "nic";
          };
          root = {
            path = "/";
            pool = "home";
            type = "disk";
          };
        };
        name = "default";
        project = "default";
      }
    ];
    projects = [];
    certificates = [];
  #  cluster = null;
  };

  # podman
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };


  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.windowManager.windowmaker.enable = true;


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  #services.avahi = {
  #  enable = true;
  #  nssmdns = false; # Disable default
  #};
  #system.nssModules = with pkgs.lib; optional (!config.services.avahi.nssmdns) pkgs.nssmdns;
  #system.nssDatabases.hosts = with pkgs.lib; optionals (!config.services.avahi.nssmdns) (mkMerge [
  #  (mkOrder 900 [ "mdns4_minimal [NOTFOUND=return]" ])
  #  (mkOrder 1501 [ "mdns4" ])
  #]);


  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rob = {
    isNormalUser = true;
    description = "Rob Adams";
    extraGroups = [ "networkmanager" "wheel" "incus-admin" "incus" "podman" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # pipx runs its own copy of swig. Of course it is dynamic
  programs.nix-ld.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    vim
    google-chrome
    gparted
    git
    openconnect
    networkmanager-openconnect
    # ghostty
    windowmaker
    dive
    podman-tui
    podman-compose
  ];

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
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
