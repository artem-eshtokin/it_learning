#!/usr/bin/python3

# Импорт модулей
import pandas as pd
import psycopg2

# Создание дата фрейма из файла Excel
df = pd.read_excel( '/home/de13an/XXXX/medicine.xlsx', sheet_name='hard', header=0, index_col=None )


# Визуальная проверка загрузки
# df.head()

# Просмотр названия полей
# print(df.columns)

# Переименовываем поля из кирилицы
df.rename(columns = {'Код пациента':'patient_id', 'Анализ':'analysis', 'Значение':'med_value'}, inplace = True )

# Преобразовываем поле med_value: если первый символ ячейки текст, то переводим в нижний регистр
df.med_value = df.med_value.apply(lambda x: x.lower() if(str(x)[0].isalpha()) else x)

# Если первый символ ячейки 'о' (отрицательный) или '-', то заменяем на 0. 'п' или '+' - на 1.
df.loc[(df.med_value.str[0] == 'о') | (df.med_value.str[0] == '-'), 'med_value'] = 0
df.loc[(df.med_value.str[0] == 'п') | (df.med_value.str[0] == '+'), 'med_value'] = 1

# Создаем подключение к БД
conn = psycopg2.connect(database = "XXXX",
    host = "XXXX",
    user = "XXXX",
    password = "XXXX", 
    port = "XXXX")

# Отключаем автокоммит
conn.autocommit = False

# Курсор
cursor = conn.cursor()

# Создаем таблицу
cursor.execute( """
	CREATE TABLE de13an.XXXX_med_results
	       (patient_id INT,
	       analysis VARCHAR(10),
	       med_value NUMERIC(6, 2));
	""" )

# Переносим данные из датафрейма в таблицу
cursor.executemany( """
	INSERT INTO de13an.XXXX_med_results 
	       (patient_id,
	       analysis,
	       med_value)
	       VALUES( %s, %s, %s )""", df.values.tolist() )

conn.commit()

# Выборка данных
cursor.execute( """
    WITH tab1 AS ( -- Создаем CTE для сокращения кода и читаемости
    SELECT mn.phone,
           mn.name,
           man.name AS name_of_analysis, -- Переименовываем, т.к. имя совпадает
           CASE
            WHEN man.is_simple = 'Y' AND emr.med_value = 1 THEN 'Положительный'
            WHEN emr.med_value < man.min_value THEN 'Понижен'
            WHEN emr.med_value > man.max_value THEN 'Повышен'
           END AS report -- Заполняем заключение по условиям
      FROM de13an.XXXX_med_results AS emr -- Соединяем таблицы
           INNER JOIN de.med_name AS mn
           ON emr.patient_id  = mn.id
           INNER JOIN de.med_an_name man
           ON emr.analysis = man.id
     WHERE (man.is_simple = 'Y' -- Выборка пациентов с анализами не в норме
           AND emr.med_value = 1)
           OR emr.med_value < man.min_value
           OR emr.med_value > man.max_value)
    SELECT phone AS Телефон, -- Переименовываем для бизнеса
           name AS Имя,
           name_of_analysis AS Название_анализа,
           report AS Заключение
      FROM tab1
     WHERE name IN ( -- Выборка по пациентам, у которых не в норме два и более анализов
                    SELECT name
                      FROM tab1
                     GROUP BY name
                    HAVING COUNT(phone) >= 2);
    """ )

# Присваеваем результат
result_table = cursor.fetchall()

# Вывод для визуальной проверки
# for r in result_table:
#	print(r)

# Создание списка с названием полей
names_columns = [n[0] for n in cursor.description]

# Формирование датафрейма
df_report = pd.DataFrame(result_table, columns = names_columns )

# Визуальная проверка загрузки
# df_report.head()

# Запись в файл
df_report.to_excel('/home/de13an/XXXX/XXXX_medicine_report.xlsx', sheet_name='hard', header=True, index=False )

# Закрываем соединение
cursor.close()
conn.close()