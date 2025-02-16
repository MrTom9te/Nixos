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

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  system.autoUpgrade = {
    enable = true;
  };
  services.fail2ban.enable = true;
  networking.hostName = "mr-tomate-server";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Manaus";

  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  # Configuração do Fish como shell padrão do sistema
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Configuração dos usuários
  users.users.root = {
    initialPassword = "senhaSegura123";  # Senha inicial para root
    shell = pkgs.fish;
  };

  users.users.tomate = {
    isNormalUser = true;
    initialPassword = "senhaSegura123"; #Lembrar de trocar a asenha depois
    description = "Usuário Tomate";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = true;
  };

  # Permitir sudo sem senha para o grupo wheel
  security.sudo.wheelNeedsPassword = false;

  services.netdata.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  nixpkgs.config.allowUnfree = true;
}
