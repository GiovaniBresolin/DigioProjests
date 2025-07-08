Projeto de Otimização de Consultas com Índices
Descrição do Projeto
Este projeto demonstra a criação de índices em um banco de dados para otimizar a performance de consultas SQL. O foco é o esquema company, onde analisamos perguntas de negócio comuns para identificar quais colunas são candidatas ideais para indexação.

A criação de índices é uma etapa crucial na otimização de bancos de dados, pois acelera significativamente as operações de busca, junção e ordenação de dados, que são a base da maioria das consultas.

Motivação para Criação dos Índices
Os índices foram criados com base nos seguintes critérios, derivados das perguntas de negócio propostas:

Colunas de Junção (JOIN): As colunas usadas para conectar tabelas (como employee.Dno e department.Dnumber) são os candidatos mais importantes. Indexá-las acelera drasticamente a operação de JOIN.

Colunas de Agrupamento (GROUP BY): A consulta que busca o departamento com o maior número de pessoas utiliza GROUP BY Dno. Um índice nesta coluna permite que o banco de dados encontre e agrupe os dados de forma muito mais eficiente.

Colunas de Filtragem (WHERE): Embora as perguntas atuais não usem filtros complexos, em um cenário real, colunas frequentemente usadas em cláusulas WHERE também seriam fortemente consideradas para indexação.

Com base nisso, os seguintes índices foram implementados:

idx_employee_Dno: Na tabela employee, coluna Dno. Essencial para a junção com department e para a contagem de funcionários por departamento.

idx_dept_locations_Dnumber: Na tabela dept_locations, coluna Dnumber. Otimiza a busca por cidades de um departamento.

A escolha de um índice B-Tree (o padrão do MySQL) é ideal para esses casos, pois ele é eficiente para buscas de igualdade (=) e ordenação, que são as operações realizadas.

-- Usar o banco de dados company
USE company;

-- =====================================================================
-- PARTE 1: CRIAÇÃO DE ÍNDICES
-- =====================================================================

-- Motivo: A coluna 'Dno' na tabela 'employee' é frequentemente usada em
-- cláusulas JOIN para conectar com a tabela 'department' e em GROUP BY
-- para agregar dados por departamento. Um índice aqui acelera essas operações.
-- Tipo de Índice: B-Tree (padrão), ideal para buscas de igualdade e ordenação.
CREATE INDEX idx_employee_Dno ON employee(Dno);

-- Motivo: A coluna 'Dnumber' na tabela 'dept_locations' é a chave estrangeira
-- que a conecta à tabela 'department'. Indexá-la é crucial para otimizar
-- a consulta que busca as localizações de um departamento.
-- Tipo de Índice: B-Tree (padrão).
CREATE INDEX idx_dept_locations_Dnumber ON dept_locations(Dnumber);


-- =====================================================================
-- PARTE 2: QUERIES PARA RESPONDER ÀS PERGUNTAS
-- =====================================================================

-- Pergunta 1: Qual o departamento com maior número de pessoas?
SELECT d.Dname, COUNT(*) AS Numero_De_Pessoas
FROM employee e
JOIN department d ON e.Dno = d.Dnumber
GROUP BY d.Dname
ORDER BY Numero_De_Pessoas DESC
LIMIT 1;

-- Pergunta 2: Quais são os departamentos por cidade?
SELECT dl.Dlocation AS Cidade, d.Dname AS Departamento
FROM department d
JOIN dept_locations dl ON d.Dnumber = dl.Dnumber
ORDER BY Cidade, Departamento;

-- Pergunta 3: Relação de empregados por departamento
SELECT d.Dname AS Departamento, CONCAT(e.Fname, ' ', e.Lname) AS Empregado
FROM employee e
JOIN department d ON e.Dno = d.Dnumber
ORDER BY Departamento, Empregado;


-- =====================================================================
-- PROCEDURE PARA O BANCO DE DADOS E-COMMERCE
-- =====================================================================

-- Seleciona o banco de dados de e-commerce
USE ecommerce_refinado;

DELIMITER \\

CREATE PROCEDURE ManageProduct(
    IN p_acao INT, -- 1: Inserir, 2: Atualizar, 3: Remover
    IN p_idProduto INT,
    IN p_nome VARCHAR(255),
    IN p_categoria VARCHAR(100),
    IN p_valor DECIMAL(10, 2)
)
BEGIN
    -- Estrutura condicional para determinar a ação
    CASE p_acao
        WHEN 1 THEN
            -- Ação 1: Inserir um novo produto
            INSERT INTO Produto (nome, categoria, valor)
            VALUES (p_nome, p_categoria, p_valor);

        WHEN 2 THEN
            -- Ação 2: Atualizar um produto existente
            UPDATE Produto
            SET
                nome = p_nome,
                categoria = p_categoria,
                valor = p_valor
            WHERE idProduto = p_idProduto;

        WHEN 3 THEN
            -- Ação 3: Remover um produto
            -- CUIDADO: Antes de remover, é preciso remover as dependências
            -- em tabelas de relacionamento para não violar as FKs.
            DELETE FROM Produto_Fornecedor WHERE idProduto = p_idProduto;
            DELETE FROM Produto_Vendedor WHERE idProduto = p_idProduto;
            DELETE FROM Produto_Estoque WHERE idProduto = p_idProduto;
            DELETE FROM Relacao_Produto_Pedido WHERE idProduto = p_idProduto;
            DELETE FROM Produto WHERE idProduto = p_idProduto;

        ELSE
            -- Feedback caso uma opção inválida seja fornecida
            SELECT 'Opção inválida. Use 1 para Inserir, 2 para Atualizar ou 3 para Remover.' AS Mensagem;

    END CASE;
END \\

DELIMITER ;

-- Exemplos de chamada da procedure de E-commerce
-- CALL ManageProduct(1, NULL, 'Teclado Mecânico', 'Acessórios', 350.00); -- Inserir
-- CALL ManageProduct(2, 4, 'Teclado Mecânico RGB', 'Acessórios', 450.00); -- Atualizar produto de ID 4
-- CALL ManageProduct(3, 4, NULL, NULL, NULL); -- Remover produto de ID 4


-- =====================================================================
-- PROCEDURE PARA UM BANCO DE DADOS DE UNIVERSIDADE (EXEMPLO)
-- =====================================================================

-- Criando um banco de dados e tabela simples para o exemplo
CREATE DATABASE IF NOT EXISTS universidade;
USE universidade;
CREATE TABLE IF NOT EXISTS aluno (
    idAluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    curso VARCHAR(100)
);

DELIMITER \\

CREATE PROCEDURE ManageAluno(
    IN p_acao INT, -- 1: Inserir, 2: Atualizar, 3: Remover
    IN p_idAluno INT,
    IN p_nome VARCHAR(255),
    IN p_curso VARCHAR(100)
)
BEGIN
    -- Estrutura condicional com IF/ELSEIF/ELSE
    IF p_acao = 1 THEN
        -- Ação 1: Inserir um novo aluno
        INSERT INTO aluno (nome, curso) VALUES (p_nome, p_curso);

    ELSEIF p_acao = 2 THEN
        -- Ação 2: Atualizar um aluno existente
        UPDATE aluno SET nome = p_nome, curso = p_curso WHERE idAluno = p_idAluno;

    ELSEIF p_acao = 3 THEN
        -- Ação 3: Remover um aluno
        DELETE FROM aluno WHERE idAluno = p_idAluno;

    ELSE
        -- Feedback para opção inválida
        SELECT 'Opção inválida. Use 1 para Inserir, 2 para Atualizar ou 3 para Remover.' AS Mensagem;

    END IF;
END \\

DELIMITER ;

-- Exemplos de chamada da procedure de Universidade
-- CALL ManageAluno(1, NULL, 'Ana Beatriz', 'Ciência da Computação'); -- Inserir
-- CALL ManageAluno(2, 1, 'Ana Beatriz Braga', 'Engenharia de Software'); -- Atualizar aluno de ID 1
-- CALL ManageAluno(3, 1, NULL, NULL); -- Remover aluno de ID 1

