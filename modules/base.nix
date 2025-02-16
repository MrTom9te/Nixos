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

  # Configuração de Rede Unificada
  networking = {
    hostName = "mr-tomate-server";
    useNetworkd = true;
    useDHCP = true;
    networkmanager.enable = false;
    nameservers = [ "8.8.8.8" "8.8.4.4" ];

    # Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  # Configuração do systemd-networkd
  systemd = {
    network = {
      enable = true;
      networks."10-ethernet" = {
        matchConfig.Type = "ether";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
        };
      };
    };

  # Configurações Básicas
  time.timeZone = "America/Manaus";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
  };

  # Configuração dos usuários
  users = {
    defaultUserShell = pkgs.bash;
    users = {
      root = {
        initialPassword = "senhaSegura123";
        shell = pkgs.bash;
      };
      admin = {
        isNormalUser = true;
        initialPassword = "senhaSegura123";
        description = "Usuário Admin";
        extraGroups = [ "wheel" ];
        shell = pkgs.bash;
      };
    };
  };

  # Configurações de segurança
  security = {
    sudo.wheelNeedsPassword = false;
    audit.enable = true;
    rtkit.enable = true;
    pam.loginLimits = [{
      domain = "@wheel";
      type = "soft";
      item = "nofile";
      value = "524288";
    }];
  };

  # Serviços
  services = {
    fail2ban.enable = true;
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = true;
    };
    netdata.enable = true;
    dbus.enable = true;
    upower.enable = true;
    acpid.enable = true;
  };

  # Configurações do Sistema
  nixpkgs.config.allowUnfree = true;

  # Configurações do Bash
  programs.bash = {
    enableCompletion = true;
    enableLsColors = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      l = "ls -CF";
    };
  };
}
