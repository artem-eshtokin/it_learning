'''
Модуль с фукнцией для проверки наличия в заданной папке актуального файла загрузки.
Данные по файлам хранятся в de13an.XXXX_meta_source_file (префикс файла, последняя дата загрузки, расширение, счетчик ошибок для отладки)
Модуль возвращает словарь с префиксом и актуальным файлом или None, если не найден.

Таким образом файлы обрабатываются ежедневно и без пропуска дней. А счетчик пропущенных дней позволяет поддержке восстановить данные.
'''

import datetime
import os

def checkf(conn):
    '''
    Функция проверки наличия файлов.
    Возвращает словарь.
    '''

    # Создаем курсор
    cursor = conn.cursor()

    # Получаем данные по файлам
    cursor.execute( "SELECT * FROM de13an.XXXX_meta_source_file" )
    records = cursor.fetchall()

    # Путь источника файлов
    dir_path = '/home/de13an/XXXX/project'

    # Словарь актуальных файлов для работы главного скрипта
    file_lst = dict()
    # Список файлов в директории
    dir_files = os.listdir(dir_path)

    # Счетчик сущностей для лога
    s_count = len(records)

    for row in records:
        filename = f'{row[0]}_{(row[1]+datetime.timedelta(days=1)).strftime("%d%m%Y")}.{row[2]}'

        if filename in dir_files:
            file_lst[row[0]] = filename
        else:
            file_lst[row[0]] = None
            cursor.execute( """UPDATE de13an.XXXX_meta_source_file SET error_days_count = %s WHERE file_name = %s;""", (row[3]+1, row[0]))
            s_count -= 1

    conn.commit()
    cursor.close()

    # В лог
    with open('/home/de13an/XXXX/project/main.log','a') as f:
        f.write(f'{datetime.datetime.now()}: INFO Найдено файлов: {s_count} из {len(records)}.\n')

    return file_lst