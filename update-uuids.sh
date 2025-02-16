#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
NC='\033[0m'

# Pegar UUIDs
ROOT_UUID=$(blkid -s UUID -o value /dev/sda3)
BOOT_UUID=$(blkid -s UUID -o value /dev/sda1)
SWAP_UUID=$(blkid -s UUID -o value /dev/sda2)

cp modules/base.nix modules/base.nix.backup
echo -e "${GREEN}Atualizando base.nix com UUIDs...${NC}"

# Criar arquivo temporário
cat > base.nix.tmp << EOF
{ config, pkgs, ... }:

{
  # Configuração do sistema de arquivos
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${ROOT_UUID}";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${BOOT_UUID}";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/${SWAP_UUID}"; } ];

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

  users.users.admin = {
    isNormalUser = true;
    initialPassword = "senhaSegura123"; #Lembrar de trocar a senha depois
    description = "Usuário Admin";
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

  # Serviços básicos
  systemd.services.NetworkManager-wait-online.enable = false;

  services = {
    dbus.enable = true;
    upower.enable = true;
    acpid.enable = true;
    netdata.enable = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  nixpkgs.config.allowUnfree = true;
}
EOF

# Mover arquivo temporário para o lugar do original
mv base.nix.tmp modules/base.nix

echo -e "${GREEN}base.nix atualizado com sucesso!${NC}"
echo "Root UUID: ${ROOT_UUID}"
echo "Boot UUID: ${BOOT_UUID}"
echo "Swap UUID: ${SWAP_UUID}"
