{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Shells e Utilitários Básicos
    bash
    fish
    zsh
    tmux
    htop
    btop
    neofetch
    tree
    wget
    curl
    git
    zip
    unzip
    gnupg
    openssl

    # Editores de Terminal
    vim
    neovim
    nano

    # Linguagens de Programação
    ## Python
    python3
    python311Packages.pip
    python311Packages.ipython

    ## JavaScript/Node.js
    nodejs_20
    yarn

    ## Rust
    rustup
    cargo

    ## Go
    go

    ## PHP
    php
    composer

    ## C/C++
    gcc
    gnumake
    cmake

    # Ferramentas de Desenvolvimento
    ## Git Tools
    git-lfs
    lazygit

    ## Banco de Dados
    sqlite

    ## Network Tools
    nmap
    netcat
    tcpdump
    mtr

    ## Build Tools
    autoconf
    automake
    pkg-config

    ## Misc Development Tools
    jq  # JSON processor
    yq  # YAML processor
    fzf  # Fuzzy finder
    ripgrep  # Better grep
    fd  # Better find
    bat  # Better cat
    exa  # Better ls
    delta  # Better git diff
  ];

  # Configurações de ambiente
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERM = "xterm-256color";
  };
}
