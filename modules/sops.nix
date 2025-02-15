{ config, pkgs, ... }:

{
  imports = [
    (builtins.fetchTarball {
      url = "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
      sha256 = ""; # Você precisará atualizar este hash
    })
  ];

  sops = {
    defaultSopsFile = ../secrets.yaml;
    age.keyFile = "/root/key.txt"; # Caminho para sua chave age
    secrets = {
      ssh_private_key = {
        owner = "tomate";
        path = "/home/tomate/.ssh/id_ed25519";
        mode = "0600";
      };
      ssh_public_key = {
        owner = "tomate";
        path = "/home/tomate/.ssh/id_ed25519.pub";
        mode = "0644";
      };
    };
  };
}
