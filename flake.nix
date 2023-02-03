# flake.nix --- the heart of my dotfiles
#
# Author:  Nopanun Laochunhanun <nopanun@pm.me> github.com/thaenalpha/dotfiles
# Acknowledgements: Henrik Lissner, Seong Yong-ju
# URLs: (gh hlissner/dotfiles sei40kr/dotfiles)
# License: MIT
#
# Welcome to ground zero. Where the whole flake gets set up and all its modules
# are loaded.

{
  description = "A grossly incandescent nixos config.";

  inputs = 
    {
      # Core dependencies.
      nixpkgs.url = "nixpkgs/nixos-unstable";             # primary nixpkgs
      nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";  # for packages on the edge

      darwin = {
        url = "github:LnL7/nix-darwin/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      home-manager.url = "github:nix-community/home-manager/master";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "nixpkgs";

      # Extras
      emacs-overlay.url  = "github:nix-community/emacs-overlay";
      nixos-hardware.url = "github:nixos/nixos-hardware";
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, darwin, ... }:
    let
      inherit (lib) attrValues elem filterAttrs genAttrs hasSuffix mkDefault
        nixosSystem optionalAttrs removeSuffix;
      inherit (darwin.lib) darwinSystem;
      inherit (lib.my) mapModules mapModulesRec mapModulesRec';

      lib = nixpkgs.lib.extend (lib: _: {
        my = import ./lib { inherit inputs lib; };
      });

      systems = [ "aarch64-darwin" "x86_64-linux" ];

      mkPkgs = pkgs: extraOverlays: system: import pkgs {
        inherit system;
        config.allowUnfree = true;  # forgive me Stallman senpai
        overlays = extraOverlays ++ (attrValues self.overlays);
      };
      pkgs = genAttrs systems (mkPkgs nixpkgs [ self.overlay ]);
      pkgs' = genAttrs systems (mkPkgs nixpkgs-unstable []);

      isLinux = hasSuffix "-linux";
      isDarwin = hasSuffix "-darwin";
      mkHost = path:
        let
          hostCfg = (import path) { inherit inputs lib pkgs'; };
          inherit (hostCfg) system;

          specialArgs = {
            inherit inputs lib;
            pkgs = pkgs.${system};
          };
          modules = [
            {
              networking.hostName = mkDefault
                (removeSuffix ".nix" (baseNameOf path));
            }
            ./modules
            (filterAttrs (n: _: !elem n [ "system" "stateVersion" ]) hostCfg)
          ];
        in
        if isLinux system then
          (nixosSystem {
            inherit system specialArgs;
            modules = modules ++ [
              {
                system = { inherit (hostCfg) stateVersion; };
                home-manager.users.${hostCfg.user.name}.home = {
                  inherit (hostCfg) stateVersion;
                };
              }
              nixos/modules
            ];
          })
        else if isDarwin system then
          (darwinSystem {
            inherit specialArgs;
            modules = modules ++ [
              {
                home-manager.users.${hostCfg.user.name}.home = {
                  inherit (hostCfg) stateVersion;
                };
              }
              darwin/modules
            ];
          })
        else abort "[mkHost] Unknown system architecture: ${system}";
    in
    {
      lib = lib.my;

      overlay = _: { system, ... }:
        { unstable = pkgs'.${system}; my = self.packages.${system}; };

      overlays = mapModules ./overlays import;

      packages = genAttrs systems (system: import ./packages {
        pkgs = pkgs.${system};
      });

      nixosModules = mapModulesRec ./modules import
        // (mapModulesRec nixos/modules import);
      nixosConfigurations = mapModules nixos/hosts mkHost;

      darwinModules = mapModulesRec ./modules import
        // (mapModulesRec darwin/modules import);
      darwinConfigurations = mapModules darwin/hosts mkHost;

      devShells = genAttrs systems (system: import ./shell.nix {
        pkgs = pkgs.${system};
      });

      templates = {
        full = {
          path = ./.;
          description = "A grossly incandescent nixos config";
        };
      } // import ./templates;
      defaultTemplate = self.templates.full;

      defaultApp.x86_64-linux = {
        type = "app";
        program = bin/hey;
      };
    };
}
