#!/bin/bash
# install-nixos.sh

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Iniciando instalação automatizada do NixOS...${NC}"

# Função para verificar erros
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro: $1${NC}"
        exit 1
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

echo -e "${GREEN}ATENÇÃO: Isso irá apagar TODOS os dados do disco $DISK${NC}"
echo "Pressione ENTER para continuar ou CTRL+C para cancelar"
read

# Particionamento
echo -e "${GREEN}Criando partições...${NC}"
if [ $UEFI_MODE -eq 1 ]; then
    # Particionamento UEFI
    parted -s $DISK -- mklabel gpt \
        mkpart primary fat32 1MiB 512MiB \
        mkpart primary linux-swap 512MiB 8512MiB \
        mkpart primary ext4 8512MiB 100%
    check_error "Falha no particionamento UEFI"
else
    # Particionamento Legacy
    parted -s $DISK -- mklabel msdos \
        mkpart primary ext4 1MiB 512MiB \
        mkpart primary linux-swap 512MiB 8512MiB \
        mkpart primary ext4 8512MiB 100%
    check_error "Falha no particionamento Legacy"
fi

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

# Montagem
echo -e "${GREEN}Montando partições...${NC}"
mount "${DISK}3" /mnt
check_error "Falha na montagem da partição root"

mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot
check_error "Falha na montagem da partição boot"

# Copiando configurações
echo -e "${GREEN}Copiando configurações...${NC}"
mkdir -p /mnt/etc/nixos
cp -r ./modules /mnt/etc/nixos/
cp ./configuration.nix /mnt/etc/nixos/
check_error "Falha na cópia das configurações"

# Gerando configuração do hardware
echo -e "${GREEN}Gerando configuração de hardware...${NC}"
nixos-generate-config --root /mnt
check_error "Falha na geração da configuração de hardware"

# Instalação
echo -e "${GREEN}Instalando NixOS...${NC}"
nixos-install --no-root-passwd
check_error "Falha na instalação"

echo -e "${GREEN}Instalação concluída com sucesso!${NC}"
echo "1. Remova a mídia de instalação"
echo "2. Digite 'reboot' para reiniciar"
echo "3. Faça login como root"
echo "4. Configure a senha do root com 'passwd'"
echo "5. Configure a senha do usuário tomate com 'passwd tomate'"
