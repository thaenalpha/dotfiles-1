{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.xfce4;
    configDir = config.dotfiles.configDir;
in {
  options.modules.desktop.xfce4 = {
    enable = mkBoolOpt false;
    withLightdm = mkBoolOpt true;
    autoLogin = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    services = {
      redshift.enable = true;
      picom.enable = true;
      xserver = {
        enable = true;
        desktopManager = {
          xterm.enable = false;
          xfce.enable = true;
        };
        displayManager = {
          defaultSession = "xfce";
          lightdm = mkIf cfg.withLightdm {
            enable = true;
            greeters.mini.enable = true;
          };

          # Enable automatic login for the user.
          autoLogin = mkIf cfg.autoLogin {
            enable = true;
            user = "${config.user.name}";
          };
        };
      };
    };

    user.packages = with pkgs; [
      (mkIf (config.hardware.pulseaudio.enable || config.services.pipewire.pulse.enable)
        xfce.xfce4-volumed-pulse)
    ];

    # suspend-then-hibernate as configured in modules.hardware.hibernate will not work,
    # because xfce4-power-manager takes over these actions.
    # This can be manually disabld:
    # https://docs.xfce.org/xfce/xfce4-power-manager/faq
  };
}
