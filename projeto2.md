Projeto de Banco de Dados: Views, Permissões e Triggers
Descrição do Projeto
Este projeto demonstra a implementação de funcionalidades avançadas de banco de dados em dois cenários distintos: company e ecommerce. O objetivo é criar uma estrutura de dados segura e automatizada, utilizando Views para controlar o acesso à informação e Triggers para manter a integridade e o histórico dos dados.

Parte 1: Views e Gerenciamento de Acessos (Cenário: Company)
Nesta seção, foram criadas várias Views (visões) para fornecer perspectivas específicas e controladas dos dados. As Views simplificam consultas complexas e aumentam a segurança, permitindo que diferentes tipos de usuários acessem apenas as informações relevantes para suas funções.

Foram criados dois perfis de usuário:

user_gerente: Um perfil com acesso amplo, capaz de visualizar informações sobre empregados, departamentos, projetos e gerência.

user_employee: Um perfil com acesso restrito, que pode visualizar informações gerais, mas não dados sensíveis como informações de outros departamentos ou gerentes.

As permissões de SELECT foram concedidas a cada usuário apenas nas Views apropriadas, garantindo o encapsulamento e a segurança dos dados.

Parte 2: Automação com Triggers (Cenário: E-commerce)
Para o cenário de e-commerce, foram implementados gatilhos (Triggers) para automatizar ações em resposta a eventos de manipulação de dados.

Trigger de Remoção (before_delete_cliente): Antes de um cliente ser removido da base de dados principal, esta trigger é acionada para salvar uma cópia dos dados do cliente em uma tabela de backup (Cliente_Backup). Isso garante que, mesmo após a exclusão da conta, um registro histórico seja mantido para fins de análise ou auditoria.

Trigger de Atualização (before_update_salario): Para o controle de alterações salariais de colaboradores, foi criada uma trigger que, antes de uma atualização na coluna de salário, registra a alteração em uma tabela de log (Salario_Log). O log armazena o ID do colaborador, o salário antigo, o novo salário e a data da modificação, criando uma trilha de auditoria completa.


-- =====================================================================
-- PARTE 1: VIEWS E PERMISSÕES (CENÁRIO: COMPANY)
-- =====================================================================

USE company;

-- View 1: Número de empregados por departamento e localidade
CREATE OR REPLACE VIEW vw_employees_by_dept_location AS
SELECT d.Dname AS Departamento, dl.Dlocation AS Localidade, COUNT(e.Ssn) AS Numero_Empregados
FROM department d
JOIN dept_locations dl ON d.Dnumber = dl.Dnumber
JOIN employee e ON d.Dnumber = e.Dno
GROUP BY d.Dname, dl.Dlocation
ORDER BY Departamento, Localidade;

-- View 2: Lista de departamentos e seus gerentes
CREATE OR REPLACE VIEW vw_dept_managers AS
SELECT d.Dname AS Departamento, CONCAT(e.Fname, ' ', e.Lname) AS Gerente
FROM department d
JOIN employee e ON d.Mgr_ssn = e.Ssn;

-- View 3: Projetos com maior número de empregados
CREATE OR REPLACE VIEW vw_projects_by_employee_count AS
SELECT p.Pname AS Projeto, COUNT(w.Essn) AS Numero_Empregados
FROM project p
JOIN works_on w ON p.Pnumber = w.Pno
GROUP BY p.Pname
ORDER BY Numero_Empregados DESC;

-- View 4: Lista de projetos, departamentos e gerentes
CREATE OR REPLACE VIEW vw_project_dept_manager AS
SELECT p.Pname AS Projeto, d.Dname AS Departamento, CONCAT(e.Fname, ' ', e.Lname) AS Gerente
FROM project p
JOIN department d ON p.Dnum = d.Dnumber
JOIN employee e ON d.Mgr_ssn = e.Ssn;

-- View 5: Quais empregados possuem dependentes e se são gerentes
CREATE OR REPLACE VIEW vw_employees_with_dependents AS
SELECT
    CONCAT(e.Fname, ' ', e.Lname) AS Empregado,
    (CASE WHEN dep.Essn IS NOT NULL THEN 'Sim' ELSE 'Não' END) AS Possui_Dependentes,
    (CASE WHEN d.Mgr_ssn = e.Ssn THEN 'Sim' ELSE 'Não' END) AS Eh_Gerente
FROM employee e
LEFT JOIN dependent dep ON e.Ssn = dep.Essn
LEFT JOIN department d ON e.Ssn = d.Mgr_ssn
GROUP BY e.Ssn;


-- Criação de Usuários e Concessão de Permissões
CREATE USER IF NOT EXISTS 'user_gerente'@'localhost' IDENTIFIED BY 'senha_gerente';
CREATE USER IF NOT EXISTS 'user_employee'@'localhost' IDENTIFIED BY 'senha_employee';

-- Permissões para o Gerente (acesso amplo)
GRANT SELECT ON company.vw_employees_by_dept_location TO 'user_gerente'@'localhost';
GRANT SELECT ON company.vw_dept_managers TO 'user_gerente'@'localhost';
GRANT SELECT ON company.vw_projects_by_employee_count TO 'user_gerente'@'localhost';
GRANT SELECT ON company.vw_project_dept_manager TO 'user_gerente'@'localhost';
GRANT SELECT ON company.vw_employees_with_dependents TO 'user_gerente'@'localhost';

-- Permissões para o Empregado (acesso restrito)
GRANT SELECT ON company.vw_projects_by_employee_count TO 'user_employee'@'localhost';
GRANT SELECT (Empregado, Possui_Dependentes) ON company.vw_employees_with_dependents TO 'user_employee'@'localhost';


-- =====================================================================
-- PARTE 2: TRIGGERS (CENÁRIO: E-COMMERCE)
-- =====================================================================

USE ecommerce_refinado;

-- Trigger de Remoção: Backup de cliente antes de deletar
-- 1. Criar a tabela de backup
CREATE TABLE IF NOT EXISTS Cliente_Backup (
    idCliente INT,
    email VARCHAR(255),
    telefone VARCHAR(20),
    endereco VARCHAR(255),
    data_remocao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Criar a trigger
DELIMITER \\
CREATE TRIGGER before_delete_cliente
BEFORE DELETE ON Cliente
FOR EACH ROW
BEGIN
    INSERT INTO Cliente_Backup (idCliente, email, telefone, endereco)
    VALUES (OLD.idCliente, OLD.email, OLD.telefone, OLD.endereco);
END \\
DELIMITER ;


-- Trigger de Atualização: Log de atualização de salário
-- 1. Criar uma tabela de Colaborador e uma de Log para o exemplo
CREATE TABLE IF NOT EXISTS Colaborador (
    idColaborador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    salario DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS Salario_Log (
    idLog INT AUTO_INCREMENT PRIMARY KEY,
    idColaborador INT,
    salario_antigo DECIMAL(10, 2),
    salario_novo DECIMAL(10, 2),
    data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserindo um colaborador para teste
INSERT INTO Colaborador (nome, salario) VALUES ('Carlos Andrade', 5000.00) ON DUPLICATE KEY UPDATE nome=nome;


-- 2. Criar a trigger
DELIMITER \\
CREATE TRIGGER before_update_salario
BEFORE UPDATE ON Colaborador
FOR EACH ROW
BEGIN
    -- Só insere no log se o valor do salário realmente mudou
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO Salario_Log (idColaborador, salario_antigo, salario_novo)
        VALUES (OLD.idColaborador, OLD.salario, NEW.salario);
    END IF;
END \\
DELIMITER ;

-- Exemplo de como a trigger de salário seria acionada:
-- UPDATE Colaborador SET salario = 5500.00 WHERE idColaborador = 1;

