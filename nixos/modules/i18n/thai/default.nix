{ config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.i18n.thai;
in
{
  options.modules.i18n.thai = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
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
  };
}
