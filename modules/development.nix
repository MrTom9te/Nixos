{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
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
