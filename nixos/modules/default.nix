{ config, inputs, lib, pkgs, ... }:

with lib;
with lib.my;
{
  imports = [ inputs.home-manager.nixosModules.home-manager ]
    ++ (mapModulesRec' (toString ./.) import);

  environment = {
    variables.NIXPKGS_ALLOW_UNFREE = "1";
    systemPackages = with pkgs; [ cached-nix-shell ];
  };
}
