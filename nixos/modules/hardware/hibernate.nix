{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.hibernate;
in {
  options.modules.hardware.hibernate = {
    enable = mkBoolOpt false;
    resumeDevice = mkOpt types.str (builtins.head config.swapDevices).device;
  };

  config = mkIf cfg.enable {

    # protectKernelImage addes 'nohibernate' to kernelParams
    security.protectKernelImage = false;

    boot.resumeDevice = cfg.resumeDevice;

    # Suspend-then-hibernate everywhere
    services.logind = {
      lidSwitch = "suspend-then-hibernate";
      extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
        IdleAction=suspend-then-hibernate
        IdleActionSec=20m
      '';

    };

    systemd.sleep.extraConfig = "HibernateDelaySec=1h";

    # Suspend the system when battery level drops to 5% or lower
    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${ pkgs.systemd }/bin/systemctl hibernate"
    '';
  };
}
