{ config, pkgs, ... }:

{
  imports =
    [
      ./modules/base.nix
      ./modules/development.nix
      ./modules/sops.nix  # Adicione esta linha
    ];
}
