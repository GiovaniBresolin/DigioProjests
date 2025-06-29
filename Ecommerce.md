# Projeto Lógico de Banco de Dados para E-commerce

## Descrição do Projeto

Este repositório contém a implementação do projeto lógico de um banco de dados para uma plataforma de e-commerce. O script SQL apresentado foi desenvolvido a partir de um modelo conceitual refinado, com o objetivo de criar a estrutura, inserir dados para teste e realizar consultas complexas que respondem a perguntas de negócio.

## Estrutura do Esquema

O esquema lógico implementa as regras de negócio e os refinamentos solicitados, incluindo:

* **Generalização/Especialização:** A entidade `Cliente` foi dividida em `ClientePF` (Pessoa Física) e `ClientePJ` (Pessoa Jurídica), garantindo que um cliente seja de um tipo ou de outro, mas nunca ambos.
* **Formas de Pagamento:** Um cliente pode registrar múltiplas formas de pagamento, que são relacionadas no momento do pedido.
* **Rastreamento de Entrega:** Cada pedido gera um registro de entrega com status e código de rastreio próprios, separando as preocupações do pedido e da logística.

## Conteúdo do Script SQL

O arquivo `ecommerce_script.sql` está organizado em três partes principais:

1.  **DDL (Data Definition Language):** Comandos `CREATE TABLE` para construir o esquema relacional, definindo chaves primárias, estrangeiras e outras restrições.
2.  **DML (Data Manipulation Language):** Comandos `INSERT INTO` para popular o banco de dados com dados de exemplo, viabilizando a execução de testes e consultas realistas.
3.  **Queries (Consultas):** Uma seleção de comandos `SELECT` que respondem a perguntas de negócio. As consultas utilizam `JOINs`, filtros `WHERE`, atributos derivados, ordenação `ORDER BY` e agregações com `GROUP BY` e `HAVING` para extrair informações valiosas dos dados.


-- =====================================================================
-- SEÇÃO 1: CRIAÇÃO DO ESQUEMA (DDL)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS ecommerce_refinado;
USE ecommerce_refinado;

DROP TABLE IF EXISTS OS_Peca, OS_Servico, Relacao_Produto_Pedido, Produto_Estoque, Produto_Fornecedor, Produto_Vendedor, Entrega, Pedido, FormaPagamento, ClientePF, ClientePJ, Cliente, Peca, Servico, VendedorTerceiro, Fornecedor, Produto, Estoque, Equipe;

CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    endereco VARCHAR(255)
);

CREATE TABLE ClientePF (
    idCliente INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    CPF VARCHAR(11) NOT NULL UNIQUE,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

CREATE TABLE ClientePJ (
    idCliente INT PRIMARY KEY,
    razaoSocial VARCHAR(255) NOT NULL,
    CNPJ VARCHAR(14) NOT NULL UNIQUE,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

CREATE TABLE Produto (
    idProduto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    categoria VARCHAR(100),
    valor DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Fornecedor (
    idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
    razaoSocial VARCHAR(255) NOT NULL,
    CNPJ VARCHAR(14) NOT NULL UNIQUE
);

CREATE TABLE Produto_Fornecedor (
    idProduto INT,
    idFornecedor INT,
    PRIMARY KEY (idProduto, idFornecedor),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (idFornecedor) REFERENCES Fornecedor(idFornecedor)
);

CREATE TABLE VendedorTerceiro (
    idVendedor INT AUTO_INCREMENT PRIMARY KEY,
    razaoSocial VARCHAR(255) NOT NULL,
    CNPJ VARCHAR(14) UNIQUE
);

CREATE TABLE Produto_Vendedor (
    idProduto INT,
    idVendedor INT,
    PRIMARY KEY (idProduto, idVendedor),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (idVendedor) REFERENCES VendedorTerceiro(idVendedor)
);

CREATE TABLE Estoque (
    idEstoque INT AUTO_INCREMENT PRIMARY KEY,
    local VARCHAR(255) NOT NULL
);

CREATE TABLE Produto_Estoque (
    idProduto INT,
    idEstoque INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (idProduto, idEstoque),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (idEstoque) REFERENCES Estoque(idEstoque)
);

CREATE TABLE FormaPagamento (
    idFormaPagamento INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT,
    tipo ENUM('Cartão de Crédito', 'Boleto', 'PIX') NOT NULL,
    dadosPagamento VARCHAR(255),
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

CREATE TABLE Pedido (
    idPedido INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT,
    idFormaPagamento INT,
    statusPedido ENUM('Processando', 'Cancelado', 'Enviado', 'Entregue') DEFAULT 'Processando',
    frete FLOAT,
    dataPedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
    FOREIGN KEY (idFormaPagamento) REFERENCES FormaPagamento(idFormaPagamento)
);

CREATE TABLE Relacao_Produto_Pedido (
    idProduto INT,
    idPedido INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (idProduto, idPedido),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido)
);

CREATE TABLE Entrega (
    idEntrega INT AUTO_INCREMENT PRIMARY KEY,
    idPedido INT NOT NULL UNIQUE,
    statusEntrega VARCHAR(255) NOT NULL,
    codigoRastreio VARCHAR(100) UNIQUE,
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido)
);

-- =====================================================================
-- SEÇÃO 2: PERSISTÊNCIA DE DADOS (DML - INSERT)
-- =====================================================================

INSERT INTO Cliente (idCliente, email, telefone, endereco) VALUES
(1, 'joao.silva@email.com', '11911112222', 'Rua A, 123'),
(2, 'techcorp@email.com', '11933334444', 'Av B, 456');

INSERT INTO ClientePF (idCliente, nome, CPF) VALUES (1, 'João da Silva', '12345678901');
INSERT INTO ClientePJ (idCliente, razaoSocial, CNPJ) VALUES (2, 'Tech Corp S.A.', '12345678000199');

INSERT INTO FormaPagamento (idCliente, tipo, dadosPagamento) VALUES
(1, 'Cartão de Crédito', '**** **** **** 1234'),
(1, 'PIX', '12345678901'),
(2, 'Boleto', 'Tech Corp S.A.');

INSERT INTO Produto (nome, categoria, valor) VALUES
('Notebook Gamer', 'Eletrônicos', 7500.00),
('Mouse Sem Fio', 'Acessórios', 150.00),
('Monitor 4K', 'Monitores', 2200.00);

INSERT INTO Fornecedor (razaoSocial, CNPJ) VALUES
('Eletrônicos Brasil Ltda', '11222333000144'),
('Importa Tudo S.A.', '44555666000177');

-- Vendedor com mesmo CNPJ de um fornecedor
INSERT INTO VendedorTerceiro (razaoSocial, CNPJ) VALUES
('Tech Imports', '99888777000166'),
('Importa Tudo S.A.', '44555666000177');

INSERT INTO Estoque (local) VALUES ('Depósito Curitiba'), ('Depósito São Paulo');

-- Relações Produto, Fornecedor, Vendedor e Estoque
INSERT INTO Produto_Fornecedor (idProduto, idFornecedor) VALUES (1, 1), (3, 1), (2, 2);
INSERT INTO Produto_Vendedor (idProduto, idVendedor) VALUES (1, 1), (2, 2);
INSERT INTO Produto_Estoque (idProduto, idEstoque, quantidade) VALUES (1, 1, 10), (2, 2, 50), (3, 1, 15);

-- Pedidos
INSERT INTO Pedido (idCliente, idFormaPagamento, statusPedido, frete) VALUES
(1, 1, 'Enviado', 50.00),
(2, 3, 'Processando', 150.00),
(1, 2, 'Entregue', 25.00);

INSERT INTO Relacao_Produto_Pedido (idPedido, idProduto, quantidade) VALUES
(1, 1, 1), (1, 2, 1), -- Pedido 1 com Notebook e Mouse
(2, 1, 2), (2, 3, 2), -- Pedido 2 com 2 Notebooks e 2 Monitores
(3, 2, 2);          -- Pedido 3 com 2 Mouses

INSERT INTO Entrega (idPedido, statusEntrega, codigoRastreio) VALUES
(1, 'Em trânsito', 'BR123456789BR'),
(3, 'Entregue ao destinatário', 'BR987654321BR');

-- =====================================================================
-- SEÇÃO 3: CONSULTAS (QUERIES)
-- =====================================================================

-- Pergunta 1: Quantos pedidos foram feitos por cada cliente?
SELECT 
    COALESCE(pf.nome, pj.razaoSocial) AS Cliente,
    COUNT(p.idPedido) AS TotalPedidos
FROM Pedido p
JOIN Cliente c ON p.idCliente = c.idCliente
LEFT JOIN ClientePF pf ON c.idCliente = pf.idCliente
LEFT JOIN ClientePJ pj ON c.idCliente = pj.idCliente
GROUP BY c.idCliente
ORDER BY TotalPedidos DESC;

-- Pergunta 2: Algum vendedor também é fornecedor? (Verificando pelo CNPJ)
SELECT v.razaoSocial, v.CNPJ
FROM VendedorTerceiro v
JOIN Fornecedor f ON v.CNPJ = f.CNPJ;

-- Pergunta 3: Relação de produtos, seus fornecedores e onde estão estocados.
SELECT
    p.nome AS Produto,
    f.razaoSocial AS Fornecedor,
    e.local AS LocalEstoque,
    pe.quantidade AS Qtd
FROM Produto p
JOIN Produto_Fornecedor pf ON p.idProduto = pf.idProduto
JOIN Fornecedor f ON pf.idFornecedor = f.idFornecedor
JOIN Produto_Estoque pe ON p.idProduto = pe.idProduto
JOIN Estoque e ON pe.idEstoque = e.idEstoque
ORDER BY p.nome;

-- Pergunta 4: Relação de nomes dos fornecedores e os nomes dos produtos que eles fornecem.
SELECT
    f.razaoSocial AS Fornecedor,
    p.nome AS Produto
FROM Fornecedor f
JOIN Produto_Fornecedor pf ON f.idFornecedor = pf.idFornecedor
JOIN Produto p ON pf.idProduto = p.idProduto
ORDER BY f.razaoSocial, p.nome;

-- Pergunta 5: Quais clientes gastaram mais de R$1.000,00 no total?
-- (Atributo derivado, JOINs para especialização, GROUP BY e HAVING)
SELECT
    COALESCE(pf.nome, pj.razaoSocial) AS Cliente,
    SUM(rpp.quantidade * p.valor) AS GastoTotal
FROM Pedido ped
JOIN Relacao_Produto_Pedido rpp ON ped.idPedido = rpp.idPedido
JOIN Produto p ON rpp.idProduto = p.idProduto
JOIN Cliente c ON ped.idCliente = c.idCliente
LEFT JOIN ClientePF pf ON c.idCliente = pf.idCliente
LEFT JOIN ClientePJ pj ON c.idCliente = pj.idCliente
GROUP BY c.idCliente
HAVING GastoTotal > 1000;

-- Pergunta 6: Listar todos os produtos da categoria 'Eletrônicos' com valor acima de R$2.000.
-- (Filtro com WHERE em múltiplas condições)
SELECT nome, categoria, valor
FROM Produto
WHERE categoria = 'Eletrônicos' AND valor > 2000;


