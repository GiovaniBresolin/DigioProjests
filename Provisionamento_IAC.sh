#!/bin/bash

# ==============================================================================
# Script para criação de estrutura de diretórios, grupos e usuários.
# Autor: Giovani Bresolin
# Data: 14/06/2025
#
# Descrição:
# Este script realiza o provisionamento completo de uma infraestrutura
# de usuários, grupos e permissões em um servidor Linux.
# Ele é idempotente, ou seja, pode ser executado múltiplas vezes
# limpando o ambiente anterior antes de criar um novo.
# ==============================================================================

echo "Iniciando a execução do script..."

# --- 1. Exclusão da Estrutura Anterior (se existir) ---
echo "Verificando e removendo estrutura antiga..."

# Excluindo usuários
echo "Removendo usuários..."
userdel -r carlos 2>/dev/null
userdel -r maria 2>/dev/null
userdel -r joao_ 2>/dev/null
userdel -r debora 2>/dev/null
userdel -r sebastiana 2>/dev/null
userdel -r roberto 2>/dev/null
userdel -r josefina 2>/dev/null
userdel -r amanda 2>/dev/null
userdel -r rogerio 2>/dev/null

# Excluindo grupos
echo "Removendo grupos..."
groupdel GRP_ADM 2>/dev/null
groupdel GRP_VEN 2>/dev/null
groupdel GRP_SEC 2>/dev/null

# Excluindo diretórios
echo "Removendo diretórios..."
rm -rf /publico
rm -rf /adm
rm -rf /ven
rm -rf /sec

echo "Limpeza concluída."

# --- 2. Criação de Diretórios ---
echo "Criando os diretórios..."
mkdir /publico
mkdir /adm
mkdir /ven
mkdir /sec

# --- 3. Criação de Grupos de Usuários ---
echo "Criando os grupos de usuários..."
groupadd GRP_ADM
groupadd GRP_VEN
groupadd GRP_SEC

# --- 4. Criação de Usuários e Associação aos Grupos ---
echo "Criando usuários e associando aos grupos..."

# Usuários do grupo ADM
useradd carlos -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_ADM
useradd maria -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_ADM
useradd joao_ -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_ADM

# Usuários do grupo VEN
useradd debora -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_VEN
useradd sebastiana -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_VEN
useradd roberto -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_VEN

# Usuários do grupo SEC
useradd josefina -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_SEC
useradd amanda -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_SEC
useradd rogerio -m -s /bin/bash -p $(openssl passwd -1 Senh@123) -G GRP_SEC

echo "Usuários criados com sucesso."

# --- 5. Especificação de Permissões ---
echo "Configurando as permissões dos diretórios..."

# Permissão total para todos no diretório /publico
chmod 777 /publico

# Define o grupo dono de cada diretório e concede permissão total para o grupo
chown root:GRP_ADM /adm
chmod 770 /adm

chown root:GRP_VEN /ven
chmod 770 /ven

chown root:GRP_SEC /sec
chmod 770 /sec

echo "Permissões configuradas com sucesso."
echo "-------------------------------------"
echo "Script finalizado! ✅"
