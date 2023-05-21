#!/usr/bin/python3

# Импорт модулей
import psycopg2
import datetime

from py_scripts.checkfiles import checkf
from py_scripts.loadfromfile import loadf
from py_scripts.loadfrombdbank import loaddb
from py_scripts.loadtodwh import loadfact
from py_scripts.loadtodwh import loadfilehist
from py_scripts.loadtodwh import loadtablehist
from py_scripts.updatemeta import updatemetafile
from py_scripts.updatemeta import updatemetatable
from py_scripts.findfraud import f_fraud

# В лог
with open('/home/de13an/XXXX/project/main.log','a') as f:
    f.write(f'{datetime.datetime.now()}: START Выполнение скрипта запущено.\n')

# Создаем подключение к БД
conn_edu = psycopg2.connect(database = "XXXX",
    host = "XXX.XXX.XXX.XXX",
    user = "XXXXXXXX",
    password = "XXXXXXXX",
    port = "XXXX")

conn_edu.autocommit = False

# Создаем подключение к БД
conn_bank = psycopg2.connect(database = "XXXX",
    host = "XXX.XXX.XXX.XXX",
    user = "XXXXXXXX",
    password = "XXXXXXXX",
    port = "XXXX")

conn_bank.autocommit = False

# Проверка файлов источников
dic_files = checkf(conn_edu)


# Загрузка из файлов в stg
loadf(dic_files, conn_edu)


# Загрузка из БД bank
loaddb(conn_edu, conn_bank)


# Загрузка в детальный слой
# stg_passport_blacklist => dwh_fact_passport_blacklist
# stg_transactions => dwh_fact_transactions
loadfact(conn_edu, dic_files)

# stg_terminals => dwh_dim_terminals_hist
loadfilehist(conn_edu, 'terminals')

# stg_cards => dwh_dim_cards_hist
loadtablehist(conn_edu, 'cards')

# stg_accounts => dwh_dim_accounts_hist
loadtablehist(conn_edu, 'accounts')

# stg_clients => dwh_dim_clients_hist
loadtablehist(conn_edu, 'clients')


# Обновление дат в meta таблицах
# meta_source_file для файлов
updatemetafile(conn_edu, dic_files)

# meta_source_table для БД bank
updatemetatable(conn_edu)


# Наполнение витрины отчетности по мошенническим операциям
f_fraud(conn_edu, [1, 2, 3, 4])


# Закрываем соединение
conn_edu.close()
conn_bank.close()

# В лог
with open('/home/de13an/XXXX/project/main.log','a') as f:
    f.write(f'{datetime.datetime.now()}: END Выполнение скрипта закончено.\n')