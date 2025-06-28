# Projeto de Banco de Dados para E-commerce

## Descrição Conceitual

Este projeto consiste na criação de um esquema de banco de dados para uma plataforma de e-commerce. O sistema gerencia as principais entidades de uma loja virtual, incluindo:

* **Clientes:** Podem ser pessoas físicas (PF) ou jurídicas (PJ), cada uma com seus dados específicos.
* **Produtos:** Itens à venda que podem ser fornecidos por múltiplos fornecedores ou vendidos por vendedores parceiros (terceiros).
* **Pedidos:** Compras realizadas pelos clientes, compostas por um ou mais produtos.
* **Pagamentos:** Clientes podem cadastrar múltiplas formas de pagamento, que são associadas a cada pedido.
* **Entregas:** Cada pedido gera uma entrega com status e código de rastreio próprios.
* **Estoque:** Controla a quantidade de produtos disponíveis em diferentes locais.

O modelo foi projetado para ser flexível e escalável, atendendo às regras de negócio de um marketplace moderno.


-- Criação do banco de dados
CREATE DATABASE ecommerce_refinado;
USE ecommerce_refinado;

-- Tabela Cliente (Generalização)
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    endereco VARCHAR(255)
);

-- Tabela Cliente Pessoa Física (Especialização)
CREATE TABLE ClientePF (
    idCliente INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    CPF VARCHAR(11) NOT NULL UNIQUE,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

-- Tabela Cliente Pessoa Jurídica (Especialização)
CREATE TABLE ClientePJ (
    idCliente INT PRIMARY KEY,
    razaoSocial VARCHAR(255) NOT NULL,
    CNPJ VARCHAR(14) NOT NULL UNIQUE,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

-- Tabela Produto
CREATE TABLE Produto (
    idProduto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(100),
    valor DECIMAL(10, 2) NOT NULL
);

-- Tabela Fornecedor
CREATE TABLE Fornecedor (
    idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
    razaoSocial VARCHAR(255) NOT NULL,
    CNPJ VARCHAR(14) NOT NULL UNIQUE
);

-- Tabela de relação Produto-Fornecedor (M:N)
CREATE TABLE Produto_Fornecedor (
    idProduto INT,
    idFornecedor INT,
    PRIMARY KEY (idProduto, idFornecedor),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (idFornecedor) REFERENCES Fornecedor(idFornecedor)
);

-- Tabela Vendedor Terceiro
CREATE TABLE VendedorTerceiro (
    idVendedor INT AUTO_INCREMENT PRIMARY KEY,
    razaoSocial VARCHAR(255) NOT NULL,
    local VARCHAR(255)
);

-- Tabela de relação Produto-Vendedor (M:N)
CREATE TABLE Produto_Vendedor (
    idProduto INT,
    idVendedor INT,
    PRIMARY KEY (idProduto, idVendedor),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (idVendedor) REFERENCES VendedorTerceiro(idVendedor)
);

-- Tabela Forma de Pagamento (associada ao cliente)
CREATE TABLE FormaPagamento (
    idFormaPagamento INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT,
    tipo ENUM('Cartão de Crédito', 'Boleto', 'PIX') NOT NULL,
    dadosPagamento VARCHAR(255), -- Ex: "**** **** **** 1234" para cartão
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

-- Tabela Pedido
CREATE TABLE Pedido (
    idPedido INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT,
    idFormaPagamento INT,
    statusPedido ENUM('Processando', 'Cancelado', 'Enviado', 'Entregue') DEFAULT 'Processando',
    descricao VARCHAR(255),
    frete FLOAT,
    dataPedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
    FOREIGN KEY (idFormaPagamento) REFERENCES FormaPagamento(idFormaPagamento)
);

-- Tabela de Relação Produto-Pedido (M:N)
CREATE TABLE Relacao_Produto_Pedido (
    idProduto INT,
    idPedido INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (idProduto, idPedido),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido)
);

-- Tabela Entrega
CREATE TABLE Entrega (
    idEntrega INT AUTO_INCREMENT PRIMARY KEY,
    idPedido INT NOT NULL,
    statusEntrega VARCHAR(255) NOT NULL,
    codigoRastreio VARCHAR(100) UNIQUE,
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido)
);

-- Tabela Estoque
CREATE TABLE Estoque (
    idEstoque INT AUTO_INCREMENT PRIMARY KEY,
    local VARCHAR(255) NOT NULL
);

-- Tabela de Relação Produto-Estoque (M:N)
CREATE TABLE Produto_Estoque (
    idProduto INT,
    idEstoque INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (idProduto, idEstoque),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (idEstoque) REFERENCES Estoque(idEstoque)
);
