{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.flatpak;
    configDir = config.dotfiles.configDir;
in {
  options.modules.services.flatpak = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      flatpak
    ];

    user.extraGroups = [ "flatpak" ];

    modules.shell.zsh.rcFiles = [ "${configDir}/flatpak/aliases.zsh" ];

    virtualisation = {
      flatpak = {
        enable = true;
      };
    };
  };
}
