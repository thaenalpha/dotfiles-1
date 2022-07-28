{ config, options, pkgs, lib, my, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.transmission;
in {
  options.modules.services.transmission = {
    enable     = mkBoolOpt false;
    gtk.enable = mkBoolOpt false;
    qt.enable  = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.transmission = {
      enable = true;
      home = "${config.user.home}/torrents";
      settings = {
        # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
        incomplete-dir-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.*.*";
        rpc-host-whitelist = "*";
        rpc-host-whitelist-enabled = true;
        ratio-limit = 0;
        ratio-limit-enabled = true;
        encryption = 2;  # require encryption
        blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
        blocklist-enabled = true;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 51413 ];
      allowedUDPPorts = [ 51413 ];
    };

    user.extraGroups = [ "transmission" ];

    # TODO using gtk or qt will not use the service settings above!
    user.packages = with pkgs;
      (if cfg.gtk.enable then [
        transmission-gtk
      ] else []) ++

      (if cfg.qt.enable then [
        transmission-qt
      ] else []);

    # transmission service does not create the neseccary directories
    system.userActivationScripts.setupTransmissionDirs = ''
      # create necessary directories
      mkdir -p ${config.services.transmission.home}/.config/transmission-daemon \
        ${config.services.transmission.settings.download-dir} \
        ${config.services.transmission.settings.incomplete-dir}
    '';
  };
}
