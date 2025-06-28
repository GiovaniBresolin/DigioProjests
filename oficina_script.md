# Projeto de Banco de Dados para Oficina: Implementação e Consultas

## Descrição do Projeto Lógico

Este repositório contém o esquema lógico e a implementação de um banco de dados para uma oficina mecânica, baseado no modelo conceitual previamente elaborado. O script SQL fornecido automatiza a criação das tabelas, o povoamento com dados de exemplo e a execução de consultas para análise.

O esquema lógico traduz o modelo conceitual em tabelas relacionais com chaves primárias e estrangeiras que garantem a integridade dos dados, representando as entidades: `Cliente`, `Veiculo`, `Equipe`, `Mecanico`, `OrdemServico`, `Servico` e `Peca`, além das tabelas de junção para os relacionamentos N:M.

## Conteúdo do Script SQL

O arquivo `oficina_script.sql` está dividido em três seções:

1.  **Criação do Esquema (DDL):** Comandos `CREATE TABLE` para todas as entidades e seus relacionamentos.
2.  **Persistência de Dados (DML):** Comandos `INSERT INTO` para popular o banco com dados de exemplo, permitindo a execução de testes e consultas.
3.  **Consultas (Queries):** Uma série de perguntas de negócio respondidas com comandos `SELECT`. As consultas demonstram o uso de `JOINs`, filtros com `WHERE`, agregações com `GROUP BY`, condições com `HAVING`, ordenação com `ORDER BY` e a criação de atributos derivados para análises complexas.


-- =====================================================================
-- SEÇÃO 1: CRIAÇÃO DO ESQUEMA (DDL)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS oficina;
USE oficina;

DROP TABLE IF EXISTS OS_Peca, OS_Servico, OrdemServico, Peca, Servico, Mecanico, Equipe, Veiculo, Cliente;

CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nomeCompleto VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(255) UNIQUE
);

CREATE TABLE Veiculo (
    idVeiculo INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT,
    placa VARCHAR(10) NOT NULL UNIQUE,
    modelo VARCHAR(100),
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

CREATE TABLE Equipe (
    idEquipe INT AUTO_INCREMENT PRIMARY KEY,
    nomeEquipe VARCHAR(255) NOT NULL
);

CREATE TABLE Mecanico (
    idMecanico INT AUTO_INCREMENT PRIMARY KEY,
    idEquipe INT,
    nomeCompleto VARCHAR(255) NOT NULL,
    especialidade VARCHAR(100),
    FOREIGN KEY (idEquipe) REFERENCES Equipe(idEquipe)
);

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

CREATE TABLE Servico (
    idServico INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valorMaoDeObra DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Peca (
    idPeca INT AUTO_INCREMENT PRIMARY KEY,
    nomePeca VARCHAR(255) NOT NULL,
    valorUnitario DECIMAL(10, 2) NOT NULL
);

CREATE TABLE OS_Servico (
    idOrdemServico INT,
    idServico INT,
    PRIMARY KEY (idOrdemServico, idServico),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico),
    FOREIGN KEY (idServico) REFERENCES Servico(idServico)
);

CREATE TABLE OS_Peca (
    idOrdemServico INT,
    idPeca INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (idOrdemServico, idPeca),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico),
    FOREIGN KEY (idPeca) REFERENCES Peca(idPeca)
);

-- =====================================================================
-- SEÇÃO 2: PERSISTÊNCIA DE DADOS (DML - INSERT)
-- =====================================================================

INSERT INTO Cliente (nomeCompleto, telefone, email) VALUES
('Carlos Silva', '41999998888', 'carlos.silva@email.com'),
('Mariana Costa', '41988887777', 'mariana.costa@email.com');

INSERT INTO Veiculo (idCliente, placa, modelo) VALUES
(1, 'ABC1234', 'Fiat Uno'),
(2, 'DEF5678', 'Honda Civic'),
(1, 'GHI9012', 'Ford Ka');

INSERT INTO Equipe (nomeEquipe) VALUES ('Equipe Motor e Transmissão'), ('Equipe Elétrica e Freios');

INSERT INTO Mecanico (idEquipe, nomeCompleto, especialidade) VALUES
(1, 'João Pereira', 'Motor'),
(1, 'Ricardo Alves', 'Transmissão'),
(2, 'Fernanda Lima', 'Elétrica'),
(2, 'Bruno Santos', 'Freios');

INSERT INTO Servico (descricao, valorMaoDeObra) VALUES
('Troca de óleo e filtro', 100.00),
('Revisão do sistema de freios', 250.00),
('Alinhamento e balanceamento', 150.00);

INSERT INTO Peca (nomePeca, valorUnitario) VALUES
('Filtro de Óleo', 45.00),
('Pastilha de Freio (par)', 180.00),
('Óleo de Motor (litro)', 55.00);

INSERT INTO OrdemServico (idVeiculo, idEquipe, dataEmissao, status, autorizacaoCliente, valorTotal) VALUES
(1, 1, '2025-06-20', 'Concluída', TRUE, 265.00),
(2, 2, '2025-06-25', 'Em Execução', TRUE, 430.00),
(3, 2, '2025-06-28', 'Aguardando Aprovação', FALSE, 150.00);

-- OS 1: Troca de óleo (1 serviço, 2 peças)
INSERT INTO OS_Servico (idOrdemServico, idServico) VALUES (1, 1);
INSERT INTO OS_Peca (idOrdemServico, idPeca, quantidade) VALUES (1, 1, 1), (1, 3, 3);

-- OS 2: Revisão de freios (1 serviço, 1 peça)
INSERT INTO OS_Servico (idOrdemServico, idServico) VALUES (2, 2);
INSERT INTO OS_Peca (idOrdemServico, idPeca, quantidade) VALUES (2, 2, 1);

-- OS 3: Alinhamento (1 serviço, 0 peças)
INSERT INTO OS_Servico (idOrdemServico, idServico) VALUES (3, 3);


-- =====================================================================
-- SEÇÃO 3: CONSULTAS (QUERIES)
-- =====================================================================

-- Pergunta 1: Quais são todos os clientes e os veículos que eles possuem?
-- (Recuperação simples com SELECT e JOIN)
SELECT c.nomeCompleto AS Cliente, v.placa, v.modelo
FROM Cliente c
JOIN Veiculo v ON c.idCliente = v.idCliente;


-- Pergunta 2: Quais ordens de serviço ainda estão aguardando a aprovação do cliente?
-- (Filtro com WHERE)
SELECT idOrdemServico, dataEmissao, valorTotal
FROM OrdemServico
WHERE status = 'Aguardando Aprovação' AND autorizacaoCliente = FALSE;


-- Pergunta 3: Qual o custo total de peças para cada ordem de serviço?
-- (Expressão para atributo derivado, JOIN, GROUP BY e ORDER BY)
SELECT
    os.idOrdemServico,
    SUM(p.valorUnitario * osp.quantidade) AS CustoTotalPecas
FROM OrdemServico os
JOIN OS_Peca osp ON os.idOrdemServico = osp.idOrdemServico
JOIN Peca p ON osp.idPeca = p.idPeca
GROUP BY os.idOrdemServico
ORDER BY CustoTotalPecas DESC;


-- Pergunta 4: Quais equipes de mecânicos geraram mais de R$ 200 em ordens de serviço concluídas?
-- (JOIN, WHERE, GROUP BY e HAVING)
SELECT
    e.nomeEquipe,
    COUNT(os.idOrdemServico) AS Qtd_OS_Concluidas,
    SUM(os.valorTotal) AS FaturamentoTotal
FROM OrdemServico os
JOIN Equipe e ON os.idEquipe = e.idEquipe
WHERE os.status = 'Concluída'
GROUP BY e.nomeEquipe
HAVING SUM(os.valorTotal) > 200;


-- Pergunta 5: Gerar um relatório completo da Ordem de Serviço de número 2.
-- (Múltiplos JOINs para uma visão complexa)
SELECT
    os.idOrdemServico AS OS,
    os.status,
    c.nomeCompleto AS Cliente,
    v.placa,
    v.modelo,
    e.nomeEquipe AS Equipe,
    GROUP_CONCAT(s.descricao SEPARATOR ', ') AS Servicos,
    GROUP_CONCAT(p.nomePeca SEPARATOR ', ') AS Pecas,
    os.valorTotal
FROM OrdemServico os
JOIN Veiculo v ON os.idVeiculo = v.idVeiculo
JOIN Cliente c ON v.idCliente = c.idCliente
JOIN Equipe e ON os.idEquipe = e.idEquipe
LEFT JOIN OS_Servico oss ON os.idOrdemServico = oss.idOrdemServico
LEFT JOIN Servico s ON oss.idServico = s.idServico
LEFT JOIN OS_Peca osp ON os.idOrdemServico = osp.idOrdemServico
LEFT JOIN Peca p ON osp.idPeca = p.idPeca
WHERE os.idOrdemServico = 2
GROUP BY os.idOrdemServico;
