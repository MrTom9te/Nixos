{ config, pkgs, ... }:

{
  imports =
    [
      ./modules/base.nix
      ./modules/development.nix
    ];
}
