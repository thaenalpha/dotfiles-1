{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.dropbox;

  package = pkgs.dropbox;
in
{
  options.modules.services.dropbox = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = [ package ];
  };
}
