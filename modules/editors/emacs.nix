# https://github.com/doomemacs/doomemacs. This module sets to meet my Doomy needs.

{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.emacs;
    configDir = config.dotfiles.configDir;
in {
  options.modules.editors.emacs = {
    enable = mkBoolOpt false;
    doom = rec {
      enable = mkBoolOpt false;
      forgeUrl = mkOpt types.str "https://github.com";
      repoUrl = mkOpt types.str "${forgeUrl}/thaenalpha/doom-emacs";
      configRepoUrl = mkOpt types.str "${forgeUrl}/thaenalpha/.doom.d";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

    user.packages = with pkgs; [
      ## Emacs itself
      binutils       # native-comp needs 'as', provided by this
      # 28.2 + native-comp
      ((emacsPackagesFor emacsNativeComp).emacsWithPackages
        (epkgs: [ epkgs.vterm ]))

      ## Doom dependencies
      git
      (ripgrep.override {withPCRE2 = true;})
      gnutls              # for TLS connectivity

      ## Optional dependencies
      fd                  # faster projectile indexing
      imagemagick         # for image-dired
      (mkIf (config.programs.gnupg.agent.enable)
        pinentry_emacs)   # in-emacs gnupg prompts
      zstd                # for undo-fu-session/undo-tree compression
      wmctrl              # for orca raise-frame

      ## Module dependencies
      # :app telega
      unstable.tdlib
      # :checkers grammar
      languagetool        # for grammar-checking
      # :checkers spell
      (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
      # :tools editorconfig
      editorconfig-core-c # per-project style config
      # :tools lookup & :lang org +roam
      sqlite
      # :tools pass
      zbar                # Bar code reader
      qrencode            # QR code encoder
      # :lang latex & :lang org (latex previews)
      texlive.combined.scheme-medium
      # :lang beancount
      beancount
      unstable.fava  # HACK Momentarily broken on nixos-unstable
      # :lang javascript +lsp
      nodePackages.typescript-language-server
      nodePackages.typescript
      nodePackages.prettier
      # :lang nix
      nixfmt
      # :lang markdown +grip, org +jupyter +roam
      pandoc
      scrot               # for screenshoting
      gnuplot
      (python3.withPackages (ps: with ps; [ grip jupyter ]))
      graphviz            # for graphviz-dot-mode
      (makeDesktopItem {
        name = "Org-Protocol";
        desktopName = "Org-Protocol";
        exec = "emacsclient %u";
        icon = "emacs";
        mimeTypes = [ "x-scheme-handler/org-protocol" ];
        categories = [ "System" ];
      })
      # :lang python +lsp
      unstable.nodePackages.pyright
      # :lang rust +lsp
      rustfmt
      unstable.rust-analyzer
      # :lang sh
      shellcheck
      unstable.shfmt
      # :lang yanl +lsp
      nodePackages.yaml-language-server
    ];

    env.PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];

    modules.shell.zsh.rcFiles = [ "${configDir}/emacs/aliases.zsh" ];

    fonts.fonts = with pkgs; [ emacs-all-the-icons-fonts alegreya meslo-lg ];

    system.userActivationScripts = mkIf cfg.doom.enable {
      installDoomEmacs = ''
        if [ ! -d "$XDG_CONFIG_HOME/emacs" ]; then
           git clone --depth=1 --single-branch "${cfg.doom.repoUrl}" "$XDG_CONFIG_HOME/emacs"
           git clone "${cfg.doom.configRepoUrl}" "$XDG_CONFIG_HOME/doom"
        fi
      '';
    };
  };
}
