'''
Модуль с фукнцией для загрузки данных из БД bank.
'''

import datetime
import pandas as pd

def loaddb(conn1, conn2):
    
    # Создаем курсоры для каждой БД
    cursor1 = conn1.cursor() # edu
    cursor2 = conn2.cursor() # bank

    # 1. Очистка stg
    cursor1.execute('''
        TRUNCATE TABLE de13an.XXXX_stg_cards;
        TRUNCATE TABLE de13an.XXXX_stg_del_cards;
        TRUNCATE TABLE de13an.XXXX_stg_accounts;
        TRUNCATE TABLE de13an.XXXX_stg_del_accounts;
        TRUNCATE TABLE de13an.XXXX_stg_clients;
        TRUNCATE TABLE de13an.XXXX_stg_del_clients;
        ''')


    # 2. Захват данных db bank в stg

    # 2.1. cards => stg
    try:
        # Из мета получаем дату последней загрузки
        cursor1.execute('''
            SELECT last_update_dt
	    	  FROM de13an.XXXX_meta_source_table
	    	 WHERE table_name = 'cards'
	    	''')
        last_upd_dt = cursor1.fetchone()[0] # Забираем из кортежа единственный элемент (формат datetime.date)

        cursor2.execute('''
            SELECT card_num,
                   account,
                   create_dt,
                   update_dt
              FROM info.cards
             WHERE COALESCE(update_dt, CAST('1199-01-01' AS DATE)) > %s
                   OR create_dt > %s
            ''', (last_upd_dt, last_upd_dt)) # Выбираем из источника по дате. Если update_dt is null, то подставляем минус бесконечность.

        records = cursor2.fetchall()
    
        # DataFrame
        col_names = [ x[0] for x in cursor2.description ]
        df = pd.DataFrame( records, columns = col_names )
        df.card_num = df.card_num.str.rstrip()

        # Переносим df в edu
        cursor1.executemany( '''
            INSERT INTO de13an.XXXX_stg_cards (
                   card_num,
                   account_num ,
                   create_dt,
                   update_dt)
            VALUES (%s, %s, %s, %s)
            ''', df.values.tolist() )

        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Данные из БД bank, таблица cards - загружены, начиная с {last_upd_dt+datetime.timedelta(days=1)}.\n')
    except Exception:
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: ERROR Ошибка загрузки из БД bank, таблица cards.\n')

    # 2.2. cards => stg_del
    try:
        cursor2.execute('SELECT card_num FROM info.cards;')
        records = cursor2.fetchall()
        df = pd.DataFrame( records, columns = ['card_num'] )
        df.card_num = df.card_num.str.rstrip()

        # Переносим df в edu
        cursor1.executemany( '''
            INSERT INTO de13an.XXXX_stg_del_cards (card_num)
            VALUES (%s)
            ''', df.values.tolist() )

        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Данные из БД bank, таблица cards - загружены в stg_del.\n')
    except Exception:
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: ERROR Ошибка загрузки из БД bank, таблица cards, stage del.\n')

    # 2.3. accounts => stg
    try:
        # Из мета получаем дату последней загрузки
        cursor1.execute('''
            SELECT last_update_dt
	    	  FROM de13an.XXXX_meta_source_table
	    	 WHERE table_name = 'accounts'
	    	''')
        last_upd_dt = cursor1.fetchone()[0] # Забираем из кортежа единственный элемент (формат datetime.date)

        cursor2.execute('''
            SELECT account,
                   valid_to,
                   client,
                   create_dt,
                   update_dt
              FROM info.accounts
             WHERE COALESCE(update_dt, CAST('1199-01-01' AS DATE)) > %s
                   OR create_dt > %s
            ''', (last_upd_dt, last_upd_dt)) # Выбираем из источника по дате. Если update_dt is null, то подставляем минус бесконечность.

        records = cursor2.fetchall()
    
        # DataFrame
        col_names = [ x[0] for x in cursor2.description ]
        df = pd.DataFrame( records, columns = col_names )

        # Переносим df в edu
        cursor1.executemany( '''
            INSERT INTO de13an.XXXX_stg_accounts (
                   account_num,
                   valid_to,
                   client,
                   create_dt,
                   update_dt)
            VALUES (%s, %s, %s, %s, %s)
            ''', df.values.tolist() )

        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Данные из БД bank, таблица accounts - загружены, начиная с {last_upd_dt+datetime.timedelta(days=1)}.\n')
    except Exception:
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: ERROR Ошибка загрузки из БД bank, таблица accounts.\n')

    # 2.4. accounts => stg_del
    try:
        cursor2.execute('SELECT account FROM info.accounts')
        records = cursor2.fetchall()
        df = pd.DataFrame( records, columns = ['account'] )

        # Переносим df в edu
        cursor1.executemany( '''
            INSERT INTO de13an.XXXX_stg_del_accounts (account_num)
            VALUES (%s)
            ''', df.values.tolist() )

        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Данные из БД bank, таблица accounts - загружены в stg_del.\n')
    except Exception:
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: ERROR Ошибка загрузки из БД bank, таблица accounts, stage del.\n')

    # 2.5. clients => stg
    try:
        # Из мета получаем дату последней загрузки
        cursor1.execute('''
            SELECT last_update_dt
	    	  FROM de13an.XXXX_meta_source_table
	    	 WHERE table_name = 'clients'
	    	''')
        last_upd_dt = cursor1.fetchone()[0] # Забираем из кортежа единственный элемент (формат datetime.date)

        cursor2.execute('''
            SELECT client_id,
                   last_name,
                   first_name,
                   patronymic,
                   date_of_birth,
                   passport_num,
                   passport_valid_to,
                   phone,
                   create_dt,
                   update_dt
              FROM info.clients
             WHERE COALESCE(update_dt, CAST('1199-01-01' AS DATE)) > %s
                   OR create_dt > %s
            ''', (last_upd_dt, last_upd_dt)) # Выбираем из источника по дате. Если update_dt is null, то подставляем минус бесконечность.

        records = cursor2.fetchall()
    
        # DataFrame
        col_names = [ x[0] for x in cursor2.description ]
        df = pd.DataFrame( records, columns = col_names )

        # Переносим df в edu
        cursor1.executemany( '''
            INSERT INTO de13an.XXXX_stg_clients (
                   client_id,
                   last_name,
                   first_name,
                   patronymic,
                   date_of_birth,
                   passport_num,
                   passport_valid_to,
                   phone,
                   create_dt,
                   update_dt)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ''', df.values.tolist() )

        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Данные из БД bank, таблица clients - загружены, начиная с {last_upd_dt+datetime.timedelta(days=1)}.\n')
    except Exception:
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: ERROR Ошибка загрузки из БД bank, таблица clients.\n')

    # 2.6. clients => stg_del
    try:
        cursor2.execute('SELECT client_id FROM info.clients')
        records = cursor2.fetchall()
        df = pd.DataFrame( records, columns = ['client_id'] )

        # Переносим df в edu
        cursor1.executemany( '''
            INSERT INTO de13an.XXXX_stg_del_clients (client_id)
            VALUES (%s)
            ''', df.values.tolist() )

        # В лог
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: INFO Данные из БД bank, таблица clients - загружены в stg_del.\n')
    except Exception:
        with open('/home/de13an/XXXX/project/main.log','a') as f:
            f.write(f'{datetime.datetime.now()}: ERROR Ошибка загрузки из БД bank, таблица clients, stage del.\n')

    # Закрываем
    conn1.commit()
    cursor1.close()
    cursor2.close()