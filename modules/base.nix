{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # Ajuste se necessário
  system.autoUpgrade = {
    enable = true;
  };
  services.fail2ban.enable = true;
  networking.hostName = "meu-servidor";
  networking.networkmanager.enable = true; # Usaremos NetworkManager

  time.timeZone = "America/Manaus";

  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

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

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  system.stateVersion = "23.11"; # Ajuste para a versão do NixOS
  nixpkgs.config.allowUnfree = true; #necessario para instalar o rustup por ele ser proprietario
}
