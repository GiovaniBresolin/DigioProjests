# 🚀 Script de Provisionamento IaC para Linux

Este repositório contém um script Bash para provisionamento de infraestrutura como código (IaC) em sistemas operacionais baseados em Linux. O script automatiza a criação de uma estrutura completa de diretórios, grupos de usuários e usuários com suas respectivas permissões.

## ✨ Sobre o Projeto

O objetivo deste script (`Provisionamento_IAC.sh`) é automatizar e padronizar a configuração inicial de um servidor, garantindo que a infraestrutura de usuários e permissões seja criada de forma rápida, consistente e livre de erros manuais.

Ele é **idempotente**, o que significa que pode ser executado várias vezes no mesmo sistema: o script primeiro remove a estrutura antiga antes de criar uma nova, garantindo um estado limpo a cada execução.

## 📋 Pré-requisitos

Para executar o script, o sistema deve atender aos seguintes requisitos:
* Um sistema operacional Linux (Debian, Ubuntu, CentOS, etc.).
* Acesso de superusuário (`root` ou `sudo`).
* O pacote `openssl` instalado (geralmente vem por padrão na maioria das distribuições).

---

## ⚙️ Como Executar o Script

Siga os passos abaixo para baixar e executar o script de provisionamento.

### 1. Clonar o Repositório
Primeiro, clone este repositório para a sua máquina local:
```sh
git clone [https://github.com/seu-usuario/seu-repositorio.git](https://github.com/seu-usuario/seu-repositorio.git)
```
*(Lembre-se de substituir `seu-usuario/seu-repositorio.git` pela URL do seu repositório no GitHub)*

### 2. Navegar para o Diretório
Acesse a pasta que foi criada pelo comando `git clone`:
```sh
cd seu-repositorio
```

### 3. Dar Permissão de Execução
Conceda a permissão de execução para o arquivo de script:
```sh
chmod +x Provisionamento_IAC.sh
```

### 4. Executar com Privilégios de Administrador

⚠️ **Importante**: O script precisa ser executado com privilégios de `sudo` para poder criar usuários, grupos e diretórios no sistema.

Execute o seguinte comando no seu terminal:
```sh
sudo ./Provisionamento_IAC.sh
```
O script irá exibir mensagens de progresso na tela, informando cada etapa da execução, desde a limpeza até a configuração final das permissões. Ao final, uma mensagem de sucesso será exibida.

---

## 🏗️ Estrutura Criada pelo Script

Após a execução bem-sucedida, a seguinte estrutura será criada no sistema:

### Diretórios
* **/publico**: Acessível por todos os usuários com permissão total (leitura, escrita e execução).
* **/adm**: Acessível apenas pelo usuário `root` e membros do grupo `GRP_ADM`.
* **/ven**: Acessível apenas pelo usuário `root` e membros do grupo `GRP_VEN`.
* **/sec**: Acessível apenas pelo usuário `root` e membros do grupo `GRP_SEC`.

### Grupos
* `GRP_ADM`
* `GRP_VEN`
* `GRP_SEC`

### Usuários
Todos os usuários são criados com a senha padrão `Senha123`.

* **Grupo GRP_ADM**:
    * `carlos`
    * `maria`
    * `joao_`
* **Grupo GRP_VEN**:
    * `debora`
    * `sebastiana`
    * `roberto`
* **Grupo GRP_SEC**:
    * `josefina`
    * `am
