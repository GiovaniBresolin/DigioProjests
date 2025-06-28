# Projeto de Banco de Dados para Oficina Mecânica

## Descrição Conceitual

Este projeto apresenta um esquema de banco de dados para um sistema de gerenciamento de uma oficina mecânica. O objetivo é controlar o fluxo de trabalho desde a chegada do veículo até a finalização do serviço.

O sistema modela as seguintes entidades principais:
* **Cliente**: O proprietário do veículo.
* **Veículo**: O carro que será consertado, ligado a um cliente.
* **Equipe**: O grupo de mecânicos responsável pelo serviço.
* **Mecânico**: Profissionais com suas especialidades, alocados em equipes.
* **Ordem de Serviço (OS)**: O documento central que registra os serviços a serem executados em um veículo, o valor, o status e a equipe responsável.
* **Serviços e Peças**: Catálogos com os valores de referência para mão de obra e peças, que são utilizados para compor o valor total da OS.

### Premissas Adotadas
* A "autorização do cliente" foi modelada como um campo do tipo `BOOLEAN` na tabela `OrdemServico`.
* A estrutura de "equipe" foi criada como uma entidade separada (`Equipe`) para agrupar os mecânicos, conforme descrito na narrativa.

-- Criação do banco de dados
CREATE DATABASE oficina;
USE oficina;

-- Tabela de Clientes
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nomeCompleto VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(255) UNIQUE
);

-- Tabela de Veículos
CREATE TABLE Veiculo (
    idVeiculo INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT,
    placa VARCHAR(10) NOT NULL UNIQUE,
    modelo VARCHAR(100),
    marca VARCHAR(100),
    ano INT,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

-- Tabela de Equipes de Mecânicos
CREATE TABLE Equipe (
    idEquipe INT AUTO_INCREMENT PRIMARY KEY,
    nomeEquipe VARCHAR(255) NOT NULL
);

-- Tabela de Mecânicos
CREATE TABLE Mecanico (
    idMecanico INT AUTO_INCREMENT PRIMARY KEY,
    idEquipe INT,
    nomeCompleto VARCHAR(255) NOT NULL,
    endereco VARCHAR(255),
    especialidade VARCHAR(100),
    FOREIGN KEY (idEquipe) REFERENCES Equipe(idEquipe)
);

-- Tabela de Ordens de Serviço (OS)
CREATE TABLE OrdemServico (
    idOrdemServico INT AUTO_INCREMENT PRIMARY KEY,
    idVeiculo INT,
    idEquipe INT,
    dataEmissao DATE NOT NULL,
    dataConclusaoPrevista DATE,
    valorTotal DECIMAL(10, 2),
    status ENUM('Aguardando Avaliação', 'Aguardando Aprovação', 'Aprovada', 'Em Execução', 'Concluída', 'Cancelada') NOT NULL,
    autorizacaoCliente BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (idVeiculo) REFERENCES Veiculo(idVeiculo),
    FOREIGN KEY (idEquipe) REFERENCES Equipe(idEquipe)
);

-- Tabela de Referência de Serviços (Mão de Obra)
CREATE TABLE Servico (
    idServico INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valorMaoDeObra DECIMAL(10, 2) NOT NULL
);

-- Tabela de Peças
CREATE TABLE Peca (
    idPeca INT AUTO_INCREMENT PRIMARY KEY,
    nomePeca VARCHAR(255) NOT NULL,
    valorUnitario DECIMAL(10, 2) NOT NULL
);

-- Tabela de Relação: Serviços na Ordem de Serviço (M:N)
CREATE TABLE OS_Servico (
    idOrdemServico INT,
    idServico INT,
    PRIMARY KEY (idOrdemServico, idServico),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico),
    FOREIGN KEY (idServico) REFERENCES Servico(idServico)
);

-- Tabela de Relação: Peças na Ordem de Serviço (M:N)
CREATE TABLE OS_Peca (
    idOrdemServico INT,
    idPeca INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (idOrdemServico, idPeca),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico),
    FOREIGN KEY (idPeca) REFERENCES Peca(idPeca)
);
