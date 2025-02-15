{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    neovim
    nano
    rustup
    php
    go
    gcc
    gnumake
    cmake
    htop
    fish
  ];
}
