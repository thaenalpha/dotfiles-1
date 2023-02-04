{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.onedrive;
  package = pkgs.onedrive;
in
{
  options.modules.services.onedrive = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = [ package ];
  };
}
