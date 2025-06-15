#!/bin/bash

# ==============================================================================
# Script para provisionamento de um servidor web Apache
# Autor: Giovani Bresolin
# Data: 15/06/2025
#
# Descrição:
# Este script realiza a atualização do servidor, instala o Apache e o Unzip,
# baixa uma aplicação web e a implanta no diretório padrão do Apache.
# ==============================================================================

echo "Iniciando o script de provisionamento do Servidor Web..."

# --- 1. Atualização do Servidor ---
echo "Atualizando os pacotes do servidor..."
apt-get update
apt-get upgrade -y
echo "Servidor atualizado com sucesso."


# --- 2. Instalação de Pacotes (Apache e Unzip) ---
echo "Instalando o Apache2 e o Unzip..."
apt-get install apache2 -y
apt-get install unzip -y
echo "Pacotes instalados com sucesso."


# --- 3. Download e Implantação da Aplicação ---
echo "Baixando e descompactando a aplicação..."

# Navega até o diretório /tmp para baixar a aplicação
cd /tmp

# Baixa o arquivo .zip da aplicação
wget https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip

# Descompacta o arquivo
unzip main.zip

# Navega para o diretório da aplicação descompactada
cd linux-site-dio-main

echo "Copiando os arquivos da aplicação para o diretório padrão do Apache..."
# Copia todo o conteúdo para o diretório do Apache
cp -R * /var/www/html/

echo "Aplicação implantada com sucesso."
echo "-------------------------------------"
echo "Script finalizado! ✅"
