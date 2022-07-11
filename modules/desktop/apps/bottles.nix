# modules/desktop/app/bottles.nix --- https://usebottles.com/
#
# Run Windows in a Bottle
# Easily run Windows software on Linux with Bottles!

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.bottles;
in {
  options.modules.desktop.apps.bottles = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      bottles
    ];
  };
}
