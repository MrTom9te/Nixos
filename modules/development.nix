{ config, pkgs, ... }:

{

  environment.variables = {
    SOPS_AGE_KEY_FILE = "./key.txt";
  };
  environment.systemPackages = with pkgs; [
    sops
    age
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
