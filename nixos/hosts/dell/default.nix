# Edit this configuration file to define what should be installed on your
# system. Help is available in the configuration.nix(5) man page and in the
# NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:

with lib;
let
  system = "x86_64-linux";
in
{
  inherit system;
  imports = [ ../home.nix ./hardware-configuration.nix ];

  # Use kernel 6.1+
  boot.kernelPackages = pkgs.${system}.unstable.linuxPackages_latest;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  ## Modules
  modules = {
    desktop = {
      bspwm.enable = true;    # tile windows as the leaves of a full binary tree
      apps = {
        bottles.enable = true;  # run Windows app in a Bottle
        rofi.enable = true; # window switcher, app launcher, & dmenu replacement
        skype.enable = true;
      };
      browsers = {
        default = "brave";
        brave.enable = true;
        firefox.enable = true;
        qutebrowser.enable = true;
      };
      media = {
        # daw.enable = true;      # make music
        documents.enable = true;
        graphics.enable = true;
        mpv.enable = true;
        recording.enable = true;
        spotify.enable = true;
      };
      term = {
        default = "xst";
        st.enable = true;
      };
    };
    dev = {
      node.enable = true;
      rust.enable = true;
      python.enable = true;
    };
    editors = {
      default = "nvim";
      emacs.enable = true;
      vim.enable = true;
    };
    shell = {
      # adl.enable = true;        # anime-downloader
      vaultwarden.enable = true;
      direnv.enable = true;
      git.enable    = true;
      gnupg.enable  = true;
      pass.enable   = true;
      tmux.enable   = true;
      zsh.enable    = true;
    };
    services = {
      docker.enable = true;
      # dropbox.enable = true;    # gui version
      google-drive.enable = true;
      onedrive.enable = true;
      ssh.enable = true;
      # teamviewer.enable = true;
      transmission.enable = true;
    };
    theme.active = "alucard";
    i18n.thai.enable = true;
  };

  ## Local config
  programs.ssh.startAgent = true;
  services.openssh.startWhenNeeded = true;

  # networking.wireless.enable = true; # Enable wifi support via wpa_supplicant.
  hardware.opengl.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us,th";
    xkbOptions = "grp:caps_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  stateVersion = "22.05";
}
