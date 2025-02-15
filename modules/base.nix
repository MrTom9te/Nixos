{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # Ajuste se necessário
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

  users.users.tomate = {
    isNormalUser = true;
    description = "Usuário Tomate";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;

  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  # Exemplo: Habilitar Nginx (opcional)
  services.nginx = {
      enable = true;
      virtualHosts."meu-servidor" = { #Configuração virtual host
        serverAliases = [ "www.meu-blog" ];
        forceSSL = true; #Força HTTPS
        root = "/var/www/html"; #Diretório raiz do site
        #Adicione outras configurações como locations, fastcgi, etc, aqui.
    };
  };



  # Permitir sudo sem senha para o grupo wheel
    security.sudo.wheelNeedsPassword = false;
  # Exemplo: Habilitar Netdata (opcional)
  services.netdata.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  nixpkgs.config.allowUnfree = true; #necessario para instalar o rustup por ele ser proprietario
}
