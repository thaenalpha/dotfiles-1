{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let hwCfg = config.modules.hardware;
    cfg = hwCfg.bluetooth;
in {
  options.modules.hardware.bluetooth = {
    enable = mkBoolOpt false;
    blueman.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.hsphfpd.enable = true;

    user.packages = with pkgs; [
      bluez-tools
    ];

    services.blueman.enable = cfg.blueman.enable;
  };
}
