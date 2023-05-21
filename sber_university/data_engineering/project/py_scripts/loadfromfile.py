'''
Модуль с фукнцией для загрузки данных из файлов.
'''

import datetime
import pandas as pd
import os
import re

def loadf(f_dict, conn):

    # Создаем курсор
    cursor = conn.cursor()

    # Путь источника файлов
    dir_path = '/home/de13an/XXXX/project/'

    # Перебираем словарь
    for t_k, t_v in f_dict.items():
        
        # Если для сущности не указан файл, то в лог пишем ошибку
        if t_v == None: 
            # В лог
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: ERROR Файл для сущности {t_k} отсутствует и не обработан.\n')
        
        # Если сущность passport_blacklist
        elif t_k == "passport_blacklist":
            df = pd.read_excel( dir_path + t_v, sheet_name='blacklist', header=0, index_col=None )
            # Выборка данных на актуальные дату (по названию файла, вместо запроса SQL meta) - через pandas для разнообразия
            d_date = re.search(r'_(\d{8})\.', t_v).group(1)
            df = df.loc[df['date'] == f"{d_date[4:]}-{d_date[2:4]}-{d_date[:2]}"]

            cursor.executemany( """INSERT INTO de13an.XXXX_stg_passport_blacklist( entry_dt, passport_num)
                                   VALUES (%s, %s);""", df.values.tolist() )
            # В лог
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: INFO Файл {t_v} для сущности {t_k} загружен в stg.\n')

        # Если сущность terminals
        elif t_k == "terminals":
            df = pd.read_excel( dir_path + t_v, sheet_name='terminals', header=0, index_col=None )

            # Из мета получаем дату последней загрузки
            cursor.execute('''
                SELECT last_update_dt + interval '1 day'
                  FROM de13an.XXXX_meta_source_file
                 WHERE file_name = 'terminals'
            ''')
            dt_of_load = cursor.fetchone()[0]
            
            # Добавляем дату загрузки данных
            df.loc[:, 'dt_of_load'] = dt_of_load

            # stg
            cursor.execute('TRUNCATE TABLE de13an.XXXX_stg_terminals')
            cursor.executemany( """INSERT INTO de13an.XXXX_stg_terminals( terminal_id, terminal_type, terminal_city, terminal_address, dt_of_load)
                                   VALUES (%s, %s, %s, %s, %s);""", df.values.tolist() )

            # В лог
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: INFO Файл {t_v} для сущности {t_k} загружен в stg.\n')

        # Если сущность transactions
        elif t_k == "transactions":
            df = pd.read_csv( dir_path + t_v, sep=';', header=0, index_col=None, decimal=',', converters={'trans_id':str})
            
            cursor.execute('TRUNCATE TABLE de13an.XXXX_stg_transactions')
            cursor.executemany( """INSERT INTO de13an.XXXX_stg_transactions( trans_id, trans_date, amt, card_num, oper_type, oper_result, terminal)
                                   VALUES (%s, %s, %s, %s, %s, %s, %s);""", df.values.tolist() )
            # В лог
            with open('/home/de13an/XXXX/project/main.log','a') as f:
                f.write(f'{datetime.datetime.now()}: INFO Файл {t_v} для сущности {t_k} загружен в stg.\n')

    # Закрываем
    conn.commit()
    cursor.close()

    
    # Архивируем файлы
    for t_k, t_v in f_dict.items():
        if t_v == None:
            continue
        os.rename(dir_path + t_v, dir_path + t_v + '.backup')
        os.replace(dir_path + t_v + '.backup', dir_path + 'archive/' + t_v + '.backup')
         
        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Файл {t_k} переименован и отправлен в архив.\n')

