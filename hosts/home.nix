{ config, lib, ... }:

with builtins;
with lib;
let blocklist = fetchurl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
in {
  networking.extraHosts = ''
    192.168.1.1   router.home

    # Hosts
    ${optionalString (config.time.timeZone == "Asia/Bangkok") ''
        192.168.1.12  dell.home
      ''}

    # Block garbage
    ${optionalString config.services.xserver.enable (readFile blocklist)}
  '';

  ## Location config -- since Bangkok is my 127.0.0.1
  time.timeZone = mkDefault "Asia/Bangkok";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";
  # For redshift, mainly
  location = (if config.time.timeZone == "Asia/Bangkok" then {
    latitude = 13.75139;
    longitude = 100.51735;
  } else {});

  # So the vaultwarden CLI knows where to find my server.
  modules.shell.vaultwarden.config.server = "bitwarden.com";
}
