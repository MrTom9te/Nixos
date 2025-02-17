#!/bin/bash
# install-nixos.sh

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root"
  exit 1
fi

# Verificar conexão com internet
if ! ping -c 1 8.8.8.8 &> /dev/null; then
  echo "Sem conexão com a internet. Configurando..."
  # Tentar configurar rede
  ip link set dev $(ip link | grep -o "en[^:]*" | head -n1) up
  dhclient $(ip link | grep -o "en[^:]*" | head -n1)
fi

echo -e "${GREEN}Iniciando instalação automatizada do NixOS...${NC}"

# Função para verificar erros
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro: $1${NC}"
        exit 1
    fi
}

# Função para verificar se um ponto de montagem está em uso
is_mounted() {
    mount | grep -q "on $1 "
}

# Função para desmontar partições se necessário
unmount_if_needed() {
    local mount_point=$1
    if is_mounted "$mount_point"; then
        echo -e "${YELLOW}Desmontando $mount_point${NC}"
        umount -R "$mount_point"
        check_error "Falha ao desmontar $mount_point"
    fi
}

# Verificar se está em modo UEFI
if [ -d "/sys/firmware/efi/efivars" ]; then
    UEFI_MODE=1
    echo "Detectado modo UEFI"
else
    UEFI_MODE=0
    echo "Detectado modo Legacy BIOS"
fi

# Definir o disco
echo -e "${GREEN}Discos disponíveis:${NC}"
lsblk
echo -e "${GREEN}Digite o dispositivo para instalação (ex: sda):${NC}"
read DISK
DISK="/dev/$DISK"

# Verificar se o disco existe
if [ ! -b "$DISK" ]; then
    echo -e "${RED}Erro: Disco $DISK não encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}ATENÇÃO: Isso irá apagar TODOS os dados do disco $DISK${NC}"
echo "Pressione ENTER para continuar ou CTRL+C para cancelar"
read

# Verificar e desmontar partições existentes
echo -e "${YELLOW}Verificando partições montadas...${NC}"
unmount_if_needed "/mnt/boot"
unmount_if_needed "/mnt"

# Desativar swap se estiver em uso
swapoff -a

# Particionamento
echo -e "${GREEN}Criando partições...${NC}"
if [ $UEFI_MODE -eq 1 ]; then
    # Particionamento UEFI
    parted -s $DISK -- mklabel gpt \
        mkpart ESP fat32 1MiB 512MiB \
        set 1 esp on \
        mkpart primary linux-swap 512MiB 8512MiB \
        mkpart primary ext4 8512MiB 100%
    check_error "Falha no particionamento UEFI"
else
    # Particionamento Legacy
    parted -s $DISK -- mklabel msdos \
        mkpart primary ext4 1MiB 512MiB \
        set 1 boot on \
        mkpart primary linux-swap 512MiB 8512MiB \
        mkpart primary ext4 8512MiB 100%
    check_error "Falha no particionamento Legacy"
fi

# Esperar pelo udev processar os eventos
sleep 2

# Formatação
echo -e "${GREEN}Formatando partições...${NC}"
if [ $UEFI_MODE -eq 1 ]; then
    mkfs.fat -F 32 "${DISK}1"
    check_error "Falha na formatação da partição EFI"
else
    mkfs.ext4 "${DISK}1"
    check_error "Falha na formatação da partição boot"
fi

mkswap "${DISK}2"
check_error "Falha na criação do swap"
swapon "${DISK}2"

mkfs.ext4 "${DISK}3"
check_error "Falha na formatação da partição root"

# Esperar pelo udev processar os eventos e pegar UUIDs
sleep 2
ROOT_UUID=$(blkid -s UUID -o value "${DISK}3")
BOOT_UUID=$(blkid -s UUID -o value "${DISK}1")
SWAP_UUID=$(blkid -s UUID -o value "${DISK}2")

# Verificar se os UUIDs foram obtidos
if [ -z "$ROOT_UUID" ] || [ -z "$BOOT_UUID" ] || [ -z "$SWAP_UUID" ]; then
    echo -e "${RED}Erro: Não foi possível obter todos os UUIDs${NC}"
    exit 1
fi

echo -e "${GREEN}UUIDs detectados:${NC}"
echo "Root: ${ROOT_UUID}"
echo "Boot: ${BOOT_UUID}"
echo "Swap: ${SWAP_UUID}"

# Montagem
echo -e "${GREEN}Montando partições...${NC}"
mount "${DISK}3" /mnt
check_error "Falha na montagem da partição root"

mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot
check_error "Falha na montagem da partição boot"

# Verificar se /mnt/etc/nixos já existe
if [ -d "/mnt/etc/nixos" ]; then
    echo -e "${YELLOW}Backup das configurações antigas...${NC}"
    mv /mnt/etc/nixos /mnt/etc/nixos.bak
fi

# Copiando configurações
echo -e "${GREEN}Copiando configurações...${NC}"
mkdir -p /mnt/etc/nixos
cp -r ./modules /mnt/etc/nixos/
cp ./configuration.nix /mnt/etc/nixos/
check_error "Falha na cópia das configurações"

# Atualizar base.nix com os UUIDs
echo -e "${GREEN}Atualizando configuração com UUIDs...${NC}"
sed -i "s|device = \"/dev/sda3\"|device = \"/dev/disk/by-uuid/${ROOT_UUID}\"|" /mnt/etc/nixos/modules/base.nix
sed -i "s|device = \"/dev/sda1\"|device = \"/dev/disk/by-uuid/${BOOT_UUID}\"|" /mnt/etc/nixos/modules/base.nix
sed -i "s|device = \"/dev/sda2\"|device = \"/dev/disk/by-uuid/${SWAP_UUID}\"|" /mnt/etc/nixos/modules/base.nix

# Gerando configuração do hardware
echo -e "${GREEN}Gerando configuração de hardware...${NC}"
nixos-generate-config --root /mnt
check_error "Falha na geração da configuração de hardware"

# Instalação
echo -e "${GREEN}Instalando NixOS...${NC}"
nixos-install --no-root-passwd
check_error "Falha na instalação"

echo -e "${GREEN}Instalação concluída com sucesso!${NC}"
echo "1. Digite 'reboot' para reiniciar"
echo "2. Remova a mídia de instalação"
echo "3. Faça login como root"
echo "4. Configure a senha do root com 'passwd'"
echo "5. Configure a senha do usuário admin com 'passwd admin'"
