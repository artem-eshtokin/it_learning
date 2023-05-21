-- ОТЛАДКА
/*
-- Быстрый селект

SELECT * FROM de13an.XXXX_meta_source_file;
SELECT * FROM de13an.XXXX_meta_source_table;


SELECT * FROM de13an.XXXX_stg_passport_blacklist;
SELECT * FROM de13an.XXXX_stg_terminals;
SELECT * FROM de13an.XXXX_stg_transactions;

SELECT * FROM de13an.XXXX_stg_cards;
SELECT * FROM de13an.XXXX_stg_accounts;
SELECT * FROM de13an.XXXX_stg_clients;

SELECT * FROM de13an.XXXX_stg_del_cards;
SELECT * FROM de13an.XXXX_stg_del_accounts;
SELECT * FROM de13an.XXXX_stg_del_clients;


SELECT * FROM de13an.XXXX_dwh_fact_passport_blacklist;
SELECT * FROM de13an.XXXX_dwh_dim_terminals_hist;
SELECT * FROM de13an.XXXX_dwh_fact_transactions;

SELECT * FROM de13an.XXXX_dwh_dim_cards_hist;
SELECT * FROM de13an.XXXX_dwh_dim_accounts_hist;
SELECT * FROM de13an.XXXX_dwh_dim_clients_hist;


SELECT * FROM de13an.XXXX_rep_fraud;

*/

/*
-- Быстрая очистка

TRUNCATE TABLE de13an.XXXX_meta_source_file;
TRUNCATE TABLE de13an.XXXX_meta_source_table;


TRUNCATE TABLE de13an.XXXX_stg_passport_blacklist;
TRUNCATE TABLE de13an.XXXX_stg_terminals;
TRUNCATE TABLE de13an.XXXX_stg_transactions;

TRUNCATE TABLE de13an.XXXX_stg_cards;
TRUNCATE TABLE de13an.XXXX_stg_accounts;
TRUNCATE TABLE de13an.XXXX_stg_clients;

TRUNCATE TABLE de13an.XXXX_stg_del_cards;
TRUNCATE TABLE de13an.XXXX_stg_del_accounts;
TRUNCATE TABLE de13an.XXXX_stg_del_clients;

TRUNCATE TABLE de13an.XXXX_dwh_fact_passport_blacklist;
TRUNCATE TABLE de13an.XXXX_dwh_dim_terminals_hist;
TRUNCATE TABLE de13an.XXXX_dwh_fact_transactions;

TRUNCATE TABLE de13an.XXXX_dwh_dim_cards_hist;
TRUNCATE TABLE de13an.XXXX_dwh_dim_accounts_hist;
TRUNCATE TABLE de13an.XXXX_dwh_dim_clients_hist;

TRUNCATE TABLE  de13an.XXXX_rep_fraud;

*/

-- БЛОК DDL

-- МЕТА-ТАБЛИЦЫ
-- Таблица метаданных для названия файлов источника и последняя дата обработки
CREATE TABLE de13an.XXXX_meta_source_file (
	file_name        VARCHAR(50),
	last_update_dt   DATE,
	file_extension   VARCHAR(10),
	error_days_count INT
    );
-- Наполнение первичными данными
INSERT INTO de13an.XXXX_meta_source_file ( file_name, last_update_dt, file_extension, error_days_count ) 
VALUES ( 'passport_blacklist', '2021-02-28', 'xlsx', 0 ),
       ( 'terminals', '2021-02-28', 'xlsx', 0 ),
       ( 'transactions', '2021-02-28', 'txt', 0 );


-- Таблица метаданных для названия файлов источника и последняя дата обработки
CREATE TABLE de13an.XXXX_meta_source_table (
	table_name       VARCHAR(50),
	last_update_dt   DATE,
	error_days_count INT
    );
-- Наполнение первичными данными
INSERT INTO de13an.XXXX_meta_source_table ( table_name, last_update_dt, error_days_count ) 
VALUES ( 'cards', '1899-01-01', 0 ),
       ( 'accounts', '1899-01-01', 0 ),
       ( 'clients', '1899-01-01', 0 );


-- STAGE-ТАБЛИЦЫ
-- Таблица stage для паспортов
CREATE TABLE de13an.XXXX_stg_passport_blacklist (
	passport_num VARCHAR(11),
	entry_dt     DATE
    );

-- Таблица stage для терминалов
CREATE TABLE de13an.XXXX_stg_terminals (
	terminal_id      VARCHAR(5),
	terminal_type    VARCHAR(3),
	terminal_city    VARCHAR(30),
	terminal_address VARCHAR(100),
	dt_of_load       DATE
    );
   
-- Таблица stage для транзакций
CREATE TABLE de13an.XXXX_stg_transactions (
	trans_id    VARCHAR(15),
	trans_date  TIMESTAMP,
	card_num    VARCHAR(22),
	oper_type   VARCHAR(10),
    amt         DECIMAL(10,2),
    oper_result VARCHAR(10), 
	terminal    VARCHAR(5)
    );

-- Таблица stage для карт
CREATE TABLE de13an.XXXX_stg_cards (
    card_num    VARCHAR(22),
    account_num VARCHAR(20),
    create_dt   DATE,
    update_dt   DATE
    );

-- Таблица stage для удаленных карт
CREATE TABLE de13an.XXXX_stg_del_cards (
    card_num VARCHAR(22)
    );

-- Таблица stage для счетов
CREATE TABLE de13an.XXXX_stg_accounts (
    account_num VARCHAR(20),
    valid_to    DATE,
    client      VARCHAR(10),
    create_dt   DATE,
    update_dt   DATE
    );

-- Таблица stage для удаленных счетов
CREATE TABLE de13an.XXXX_stg_del_accounts (
    account_num VARCHAR(20)
    );

-- Таблица stage для клиентов
CREATE TABLE de13an.XXXX_stg_clients (
    client_id         VARCHAR(10),
    last_name         VARCHAR,
    first_name        VARCHAR,
    patronymic        VARCHAR,
    date_of_birth     DATE,
    passport_num      VARCHAR,
    passport_valid_to DATE,
    phone             VARCHAR(20),
    create_dt         DATE,
    update_dt         DATE
    );

-- Таблица stage для удаленных клиентов
CREATE TABLE de13an.XXXX_stg_del_clients (
    client_id VARCHAR(10)
    );

-- DWH-ТАБЛИЦЫ
-- Фактовая таблица для паспортов
CREATE TABLE de13an.XXXX_dwh_fact_passport_blacklist (
	passport_num VARCHAR(11),
	entry_dt     DATE
    );

-- SCD2 для терминалов
CREATE TABLE de13an.XXXX_dwh_dim_terminals_hist (
	terminal_id      VARCHAR(5),
	terminal_type    VARCHAR(3),
	terminal_city    VARCHAR(30),
	terminal_address VARCHAR(100),
	effective_from   DATE,
	effective_to     DATE,
	deleted_flg      CHAR(1)
    );   
   
-- Фактовая таблица для транзакций
CREATE TABLE de13an.XXXX_dwh_fact_transactions (
	trans_id    VARCHAR(15),
	trans_date  TIMESTAMP,
	card_num    VARCHAR(22),
	oper_type   VARCHAR(10),
    amt         DECIMAL(10,2),
    oper_result VARCHAR(10), 
	terminal    VARCHAR(5)
    );

-- SCD2 для карт
CREATE TABLE de13an.XXXX_dwh_dim_cards_hist (
    card_num         VARCHAR(22),
    account_num      VARCHAR(20),
    effective_from   DATE,
	effective_to     DATE,
	deleted_flg      CHAR(1)
    );

-- SCD2 для счетов
CREATE TABLE de13an.XXXX_dwh_dim_accounts_hist (
    account_num      VARCHAR(20),
    valid_to         DATE,
    client           VARCHAR(10),
    effective_from   DATE,
	effective_to     DATE,
	deleted_flg      CHAR(1)
    );

-- SCD2 для клиентов
CREATE TABLE de13an.XXXX_dwh_dim_clients_hist (
    client_id         VARCHAR(10),
    last_name         VARCHAR,
    first_name        VARCHAR,
    patronymic        VARCHAR,
    date_of_birth     DATE,
    passport_num      VARCHAR,
    passport_valid_to DATE,
    phone             VARCHAR(20),
    effective_from    DATE,
	effective_to      DATE,
	deleted_flg       CHAR(1)
    );


-- REPORT-ТАБЛИЦЫ
-- Отчет по фрауду

CREATE TABLE de13an.XXXX_rep_fraud (
    event_dt   TIMESTAMP,
    passport   VARCHAR,
    fio        VARCHAR,
    phone      VARCHAR(20),
    event_type INTEGER,
    report_dt  DATE
    );