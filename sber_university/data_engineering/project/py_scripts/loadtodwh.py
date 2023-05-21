'''
Модуль с двумя фукнциями для загрузки данных из stage таблиц в dwh.
'''

import datetime

def loadfact(conn, f_dict):
    '''
    Функция загрузки фактовых таблиц
    '''

    # Создаем курсор
    cursor = conn.cursor()

    # Копируем паспорта
    if f_dict['passport_blacklist'] != None:
        try:
            cursor.execute( '''
                INSERT INTO de13an.XXXX_dwh_fact_passport_blacklist
                            (passport_num,
                            entry_dt)
                SELECT passport_num,
                       entry_dt
                  FROM de13an.XXXX_stg_passport_blacklist;
                ''' )
    
            # В лог
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: INFO Данные passport_blacklist загружены из stage в target.\n')
        except Exception:
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: ERROR Ошибка загрузки passport_blacklist из stage в target.\n')

    # Копируем транзакции
    if f_dict['transactions'] != None:
        try:
            cursor.execute( '''
                INSERT INTO de13an.XXXX_dwh_fact_transactions
                            (trans_id, trans_date, card_num, oper_type, amt, oper_result, terminal)
                SELECT trans_id,
                       trans_date,
                       card_num,
                       oper_type,
                       amt,
                       oper_result, 
                       terminal
                  FROM de13an.XXXX_stg_transactions;
                ''' )
    
            # В лог
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: INFO Данные transactions загружены из stage в target.\n')
        except Exception:
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: ERROR Ошибка загрузки transactions из stage в target.\n')

    conn.commit()
    cursor.close()


def loadfilehist(conn, table):
    '''
    Функция загрузки scd2 таблиц, у которых источник был файл
    '''

    # Путь до sql-скриптов
    dir_path = '/home/de13an/XXXX/project/sql_scripts/'
    scr_name = 'scd2_' + table + '.sql'

    # Считываем sql-скрипт
    f = open(dir_path + scr_name, 'r')
    sql_script = f.read()
    f.close()

    # Создаем курсор
    cursor = conn.cursor()

    # Получаем кол-во ошибок загрузки файла
    cursor.execute('''SELECT error_days_count
                        FROM de13an.XXXX_meta_source_file
                       WHERE file_name = %s
                   ''', [table])
    err = cursor.fetchone()[0]

    # Разделияем скрипт на отдельные команды
    sql_commands = sql_script.split(';')

    if err == 0:
        # Выполняем поочередно команды
        for sql_com in sql_commands:
            if sql_com != '':
                cursor.execute(sql_com)
                conn.commit()
        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Данные {table} загружены из stage в target.\n')
    else:
        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: ERROR Загрузка {table} пропущена - отсутствуют данные.\n')


    conn.commit()
    cursor.close()


def loadtablehist(conn, table):
    '''
    Функция загрузки scd2 таблиц, у которых источник был БД.
    '''

    # Путь до sql-скриптов
    dir_path = '/home/de13an/XXXX/project/sql_scripts/'
    scr_name = 'scd2_' + table + '.sql'

    # Считываем sql-скрипт
    f = open(dir_path + scr_name, 'r')
    sql_script = f.read()
    f.close()

    # Создаем курсор
    cursor = conn.cursor()

    # Проверяем stage
    table_name = 'de13an.XXXX_stg_' + table
    cursor.execute('SELECT COUNT(*) FROM %s' % (table_name,))
    err = cursor.fetchone()[0]

    # Разделияем скрипт на отдельные команды
    sql_commands = sql_script.split(';')

    if err != 0:
        # Выполняем поочередно команды
        for sql_com in sql_commands:
            if sql_com != '':
                cursor.execute(sql_com)
                conn.commit()
        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Данные {table} загружены из stage в target.\n')
    else:
        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: ERROR Загрузка {table} пропущена - отсутствуют данные.\n')

    conn.commit()
    cursor.close()