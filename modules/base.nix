{ config, pkgs, ... }:

{
  # Configuração do sistema de arquivos
  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/sda2"; } ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  # Configuração de Rede - versão mais simples e robusta
  networking = {
    hostName = "mr-tomate-server";
    useNetworkd = true;
    useDHCP = true;  # Habilita DHCP global
    networkmanager.enable = false;  # Desabilita NetworkManager

    # DNS Fallback
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };

  # Configuração do systemd-networkd
  systemd = {
    network = {
      enable = true;
      # Configuração automática para todas as interfaces ethernet
      networks."10-ethernet" = {
        matchConfig.Type = "ether";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
        };
      };
    };
    # Desabilita wait-online
    services.systemd-networkd-wait-online.enable = false;
  };

  services.fail2ban.enable = true;
  time.timeZone = "America/Manaus";

  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
  };

  # Configuração de logs
  services.journald = {
    extraConfig = ''
      SystemMaxUse=100M
      MaxRetentionSec=1week
    '';
  };

  # Configuração do Bash como shell padrão do sistema
  users.defaultUserShell = pkgs.bash;

  # Configuração dos usuários
  users.users.root = {
    initialPassword = "senhaSegura123";
    shell = pkgs.bash;
  };

  # Configurações de segurança
  security = {
    sudo.wheelNeedsPassword = false;
    audit.enable = true;
    rtkit.enable = true;
    # Limitar processos do usuário
    pam.loginLimits = [
      {
        domain = "@wheel";
        type = "soft";
        item = "nofile";
        value = "524288";
      }
    ];
  };

  users.users.admin = {
    isNormalUser = true;
    initialPassword = "senhaSegura123";
    description = "Usuário Admin";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = true;
  };

  # Serviços e Firewall
  services = {
    netdata.enable = true;
    # Serviços básicos
    dbus.enable = true;
    upower.enable = true;
    acpid.enable = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  nixpkgs.config.allowUnfree = true;

  # Desabilita o timeout do NetworkManager
  systemd.services.NetworkManager-wait-online.enable = false;

  # Configurações do Bash
  programs.bash = {
    enableCompletion = true;
    enableLsColors = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      l = "ls -CF";
    };
    shellInit = ''
      # Configurações adicionais do Bash
      export HISTSIZE=10000
      export HISTFILESIZE=20000
      export HISTCONTROL=ignoreboth
      shopt -s histappend
      shopt -s checkwinsize
      export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    '';
  };
}
