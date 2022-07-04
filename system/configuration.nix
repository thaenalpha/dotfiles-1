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
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "th_TH.utf8";
    LC_IDENTIFICATION = "th_TH.utf8";
    LC_MEASUREMENT = "th_TH.utf8";
    LC_MONETARY = "th_TH.utf8";
    LC_NAME = "th_TH.utf8";
    LC_NUMERIC = "th_TH.utf8";
    LC_PAPER = "th_TH.utf8";
    LC_TELEPHONE = "th_TH.utf8";
    LC_TIME = "th_TH.utf8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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
  users.users.nopan = {
    isNormalUser = true;
    description = "Nopanun Laochunhanun";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  nixpkgs.overlays =
    let
      # Change this to a rev sha to pin
      moz-rev = "master";
      moz-url = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${moz-rev}.tar.gz";};
      nightlyOverlay = (import "${moz-url}/firefox-overlay.nix");
    in [
      nightlyOverlay
    ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    # Doom Emacs required dependencies
    ripgrep
    # optional dependencies
    coreutils # basic GNU utilities
    fd
    clang

    htop
    latest.firefox-nightly-bin
    # gimp
    # kdenlive
    fish
    dropbox
    # gdrive
    onedrive   
    teams
    pass
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services = {
  #   Enable the OpenSSH daemon.
    openssh.enable = true;
  #   Enable the Emacs daemon.
    emacs.enable = true;
    emacs.package = with pkgs; ((emacsPackagesFor emacs28NativeComp).emacsWithPackages (epkgs: [ epkgs.vterm ]));
    emacs.defaultEditor = true;
  };
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
