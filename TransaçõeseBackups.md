Projeto de Banco de Dados: Transações e Backups
Descrição do Projeto
Este projeto demonstra a aplicação de conceitos essenciais de gerenciamento e segurança de dados em MySQL. O trabalho está dividido em três partes:

Transações Simples: Execução de um bloco de comandos SQL como uma única unidade de trabalho para garantir a consistência dos dados.

Transações em Stored Procedures: Encapsulamento de uma transação complexa dentro de uma procedure, com tratamento de erros para realizar ROLLBACK automaticamente em caso de falha.

Backup e Recovery: Utilização do utilitário mysqldump para criar um backup completo do banco de dados e-commerce e o processo para restaurá-lo.

Parte 1 e 2: Scripts de Transações (Arquivo: transactions.sql)
O arquivo SQL contém exemplos práticos de transações.

Transação Simples: Demonstra como desabilitar o autocommit para inserir um novo produto e atualizar seu preço, confirmando as mudanças apenas com um COMMIT explícito.

Procedure com Transação: Apresenta a procedure CreateNewOrder, que insere um novo pedido e seus itens. A operação é atômica: se qualquer etapa falhar (ex: um produto não existe), a transação inteira é desfeita (ROLLBACK) para evitar dados inconsistentes.

Parte 3: Backup e Recovery (Instruções)
Esta seção explica como realizar o backup e a restauração do banco de dados usando a linha de comando.

Como Fazer o Backup 💾
Use o utilitário mysqldump no seu terminal (não dentro do cliente MySQL). O comando abaixo cria um arquivo .sql com toda a estrutura e dados do seu banco, incluindo procedures e eventos.

Backup de um único banco de dados (e-commerce):

Bash

mysqldump -u seu_usuario -p --routines --events ecommerce_refinado > ecommerce_backup.sql
Backup de múltiplos bancos de dados:

Bash

mysqldump -u seu_usuario -p --databases ecommerce_refinado company > varios_bancos_backup.sql
Explicação dos Parâmetros:

-u seu_usuario: Especifica o seu nome de usuário do MySQL.

-p: Solicita a senha de forma segura.

--routines: Garante que suas Stored Procedures e Functions sejam incluídas no backup.

--events: Garante que seus Events agendados sejam incluídos.

> ecommerce_backup.sql: Redireciona a saída do comando para um arquivo SQL.

Como Restaurar o Banco de Dados (Recovery) 🔄
Para restaurar, você precisa de um banco de dados vazio e então importar o arquivo de backup para dentro dele.

Crie o banco de dados (se não existir):

SQL

CREATE DATABASE ecommerce_restaurado;
Execute o comando de restauração no terminal:

Bash

mysql -u seu_usuario -p ecommerce_restaurado < ecommerce_backup.sql
Isso executará todos os comandos SQL contidos no arquivo de backup, recriando as tabelas, inserindo os dados e restaurando as procedures no banco de dados ecommerce_restaurado.

💻 Script SQL
SQL

-- =====================================================================
-- PARTE 1: TRANSAÇÃO SIMPLES
-- =====================================================================

\-- Usar o banco de dados de e-commerce
USE ecommerce\_refinado;

\-- Desabilitar o autocommit para controlar a transação manualmente
SET autocommit = 0;

\-- Iniciar a transação
START TRANSACTION;

\-- Inserir um novo produto
INSERT INTO Produto (nome, categoria, valor)
VALUES ('Fone de Ouvido Bluetooth', 'Acessórios', 299.90);

\-- Verificar o ID do novo produto inserido
SELECT @id\_novo\_produto := LAST\_INSERT\_ID();

\-- Aplicar um desconto promocional no novo produto
UPDATE Produto
SET valor = 249.99
WHERE idProduto = @id\_novo\_produto;

\-- Verificar como os dados estão ANTES de confirmar a transação
SELECT \* FROM Produto WHERE idProduto = @id\_novo\_produto;

\-- Confirmar todas as operações realizadas dentro da transação
COMMIT;

\-- Exemplo de ROLLBACK (desfazer)
START TRANSACTION;
DELETE FROM Produto WHERE idProduto = @id\_novo\_produto;
SELECT 'Produto deletado temporariamente...' AS Acao;
SELECT \* FROM Produto WHERE idProduto = @id\_novo\_produto; -- A consulta não retornará nada

\-- Desfazer a operação de DELETE
ROLLBACK;
SELECT 'DELETE desfeito com ROLLBACK.' AS Acao;
SELECT \* FROM Produto WHERE idProduto = @id\_novo\_produto; -- O produto está de volta

\-- Ligar o autocommit novamente (opcional, boa prática)
SET autocommit = 1;

\-- =====================================================================
\-- PARTE 2: TRANSAÇÃO COM PROCEDURE E TRATAMENTO DE ERRO
\-- =====================================================================

USE ecommerce\_refinado;

DELIMITER \\

CREATE PROCEDURE CreateNewOrder(
IN p\_idCliente INT,
IN p\_idFormaPagamento INT,
IN p\_idProduto INT,
IN p\_quantidade INT,
IN p\_frete FLOAT
)
BEGIN
DECLARE new\_order\_id INT;

-- Handler para capturar qualquer erro SQL (ex: FK não encontrada)
-- Se um erro ocorrer, o bloco BEGIN...END do handler é executado.
DECLARE exit handler FOR SQLEXCEPTION
BEGIN
-- Desfaz a transação inteira
ROLLBACK;
SELECT 'Ocorreu um erro. A criação do pedido foi desfeita.' AS Mensagem_Erro;
END;

-- Iniciar a transação
START TRANSACTION;

-- 1. Inserir o registro na tabela de Pedido
INSERT INTO Pedido (idCliente, idFormaPagamento, statusPedido, frete)
VALUES (p_idCliente, p_idFormaPagamento, 'Processando', p_frete);

-- 2. Obter o ID do pedido recém-criado
SET new_order_id = LAST_INSERT_ID();

-- 3. Inserir o produto na tabela de relacionamento
INSERT INTO Relacao_Produto_Pedido (idPedido, idProduto, quantidade)
VALUES (new_order_id, p_idProduto, p_quantidade);

-- Se todas as instruções foram executadas sem erro, confirmar a transação
COMMIT;
SELECT 'Pedido criado com sucesso!' AS Mensagem_Sucesso;


END \\

DELIMITER ;

\-- Exemplo de chamada bem-sucedida
\-- Supondo que cliente 1, forma de pagamento 1 e produto 1 existem
\-- CALL CreateNewOrder(1, 1, 1, 2, 25.50);

\-- Exemplo de chamada que irá falhar (produto com ID 999 não existe)
\-- A falha no segundo INSERT acionará o handler, que executará o ROLLBACK.
\-- Nenhum pedido será criado.
\-- CALL CreateNewOrder(1, 1, 999, 1, 15.00);
