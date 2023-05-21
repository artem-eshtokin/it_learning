'''
Модуль обновления meta таблиц
'''
import psycopg2
import datetime

def updatemetafile(conn, f_dict):
    '''
    Функция обновления meta для файлов-источников
    '''

    # Создаем курсор
    cursor = conn.cursor()

    # Перебираем словарь
    for t_k, t_v in f_dict.items():
        if t_v != None:
            dir_path = '/home/de13an/XXXX/project/sql_scripts/'
            scr_name = 'meta_' + t_k + '.sql'

            # Считываем sql-скрипт
            f = open(dir_path + scr_name, 'r')
            sql_script = f.read()
            f.close()

            cursor.execute(sql_script)
            conn.commit()

            # Проверка содержимого stage
            stg_name = 'de13an.XXXX_stg_' + t_k
            cursor.execute('''SELECT COUNT(*) FROM %s''' % (stg_name,))
            row_count = cursor.fetchone()[0]

            if row_count != 0:
                with open('/home/de13an/XXXX/project/main.log','a') as f:
                    f.write(f'{datetime.datetime.now()}: INFO Для сущности {t_k} мета-данные обновлены.\n')
            else:
                with open('/home/de13an/XXXX/project/main.log','a') as f:
                    f.write(f'{datetime.datetime.now()}: WARNING Stage для {t_k} пустой.\n')

    conn.commit()
    cursor.close()


def updatemetatable(conn):
    '''
    Функция обновления meta для таблиц-источников
    '''

    # Создаем курсор
    cursor = conn.cursor()

    # Получаем список сущностей
    cursor.execute( "SELECT * FROM de13an.XXXX_meta_source_table")
    records = cursor.fetchall()

    # Перебираем матрицу
    for row in records:

        # Проверка содержимого stage
        stg_name = 'de13an.XXXX_stg_' + row[0]
        cursor.execute('''SELECT COUNT(*) FROM %s''' % (stg_name,))
        row_count = cursor.fetchone()[0]

        if row_count != 0:

            # Собираем скрипт
            sql_script = " UPDATE de13an.XXXX_meta_source_table AS mt SET last_update_dt = COALESCE( (SELECT MAX(COALESCE(update_dt, create_dt)) FROM de13an.XXXX_stg_" + row[0] + "), mt.last_update_dt ), error_days_count = 0 WHERE table_name = '" + row[0] + "';"
            cursor.execute(sql_script)

            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: INFO Для сущности {row[0]} мета-данные обновлены.\n')

        else:

            # Собираем скрипт
            sql_script = " UPDATE de13an.XXXX_meta_source_table AS mt SET error_days_count = error_days_count + 1 WHERE table_name = '" + row[0] + "';"

            cursor.execute(sql_script)
            
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: WARNING Мета-данные для {row[0]} не обновлены, т.к. stage пустой.\n')

        conn.commit()

    cursor.close()