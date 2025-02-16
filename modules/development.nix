{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
      # Utilitários básicos
      bash
      curl
      wget
      git
      vim
      neovim
      nano
      htop
      fish
      tmux

      # Ferramentas de rede
      inetutils
      nettools
      dnsutils

      # Desenvolvimento
      rustup
      php
      go
      gcc
      gnumake
      cmake
    ];
}
