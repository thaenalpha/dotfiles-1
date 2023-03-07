{ options, config, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.ssh;
in {
  options.modules.services.ssh = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      kbdInteractiveAuthentication = false;
      passwordAuthentication = false;
    };

    user.openssh.authorizedKeys.keys =
      if config.user.name == "nopan"
      then [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAJxnemRcbcR61pv+IVz5qYAT9EpECtMhuGvbn9Lg2T thaenalpha" ]
      else [];
  };
}
