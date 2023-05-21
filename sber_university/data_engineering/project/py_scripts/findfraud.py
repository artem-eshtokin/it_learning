'''
Модуль обновления meta таблиц
'''
import psycopg2
import datetime

def f_fraud(conn, fr_type_list):
    '''
    Функция генерирования отчета.
    '''
    # Создаем курсор
    cursor = conn.cursor()

    # Путь до sql-скриптов
    dir_path = '/home/de13an/XXXX/project/sql_scripts/'

    # Запрос даты
    cursor.execute('SELECT MAX(last_update_dt) FROM de13an.XXXX_meta_source_file')
    d_date = cursor.fetchone()[0]

    # Защита от повторного заполнения отчета, запрос даты отчета
    cursor.execute('SELECT MAX(report_dt) FROM de13an.XXXX_rep_fraud')
    fr_date = cursor.fetchone()[0]

    if fr_date is None or fr_date < d_date:
        # Перебираем типы
        for fr_type in fr_type_list:
            # Название скрипта
            scr_name = 'rep_fraud_' + str(fr_type) + '.sql'

            # Считываем sql-скрипт
            f = open(dir_path + scr_name, 'r')
            sql_script = f.read()
            f.close()

            # Выполняем скрипт
            cursor.execute(sql_script)
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                    f.write(f'{datetime.datetime.now()}: INFO В отчет добавлены мошеннические операции типа "{fr_type}" за {d_date.strftime("%d.%m.%Y")}.\n')
    
    else:
        with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: WARNING Генерирование отчета по мошенническим операциям пропущено.\n')


    conn.commit()
    cursor.close()