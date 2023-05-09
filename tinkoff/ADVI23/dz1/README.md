# ДЗ SQL

"Домашнее задание в виде теста. Для ответа на некоторые вопросы вам понадобится наша учебная база данных (модель данных смотри в лекции).

Подключаемся к бд:

Устанавливаем dbeaver.
Создаем новое подключение/соединение к серверу
Выбираем субд Greenplum 
Хост: XXX.XXX.XXX.XXX
Порт: XXXX
База данных: postgres
Аутентификация: Database Native
Пользователь: XXXX
Пароль: XXXX
После этого, у вас будет доступ к данным, которые будут лежать в схеме msu_analytics. Открываем окно для написания запросов и вперед.

На прохождение теста дается 30 минут."

## Решение теста

1. Что такое реляционная база данных?
- База данных, в которой информация хранится в виде двумерных таблиц, связанных между собой

2. Выберите вариант, где при составлении запроса в верном порядке расставлены операторы:
- select, from, where, group by

3. Как вставить несколько записей в таблицу одним запросом?
- Перечислить через запятую все наборы значений после VALUES

4. Выбери пример правильно составленного запроса с использованием агрегирующей функции SUM:
- select sum(income_amt) from tbl_example;

5. Выбери пример правильно составленного запроса с использованием JOIN (считаем что в таблицах нет повторяющихся полей, кроме ключа соединения):
- select first_name, gender_cd, game_dttm from table_employee as emp inner join table_game as g on emp.employee_rk = g.employee_rk;
- select first_name, gender_cd, game_dttm from table_employee as emp left join table_game as g on emp.employee_rk = g.employee_rk where g.employee_rk is not null;
- select emp.first_name, emp.gender_cd, g.game_dttm from table_employee as emp join table_game as g on emp.employee_rk = g.employee_rk;

6. Со сколькими креативными агентствами мы работаем? Креативное агентство – это партнер без единой локации, но имеющий патент на хотя бы одну легенду. 
(Для выполнения этого задания тебе понадобится учебная БД и модель данных из лекции.)
- 4

SELECT DISTINCT par.partner_rk -- 4 партнера 
  FROM msu_analytics.partner AS par 
       LEFT JOIN msu_analytics.location AS loc 
       ON par.partner_rk = loc.partner_rk 
       INNER JOIN msu_analytics.legend AS leg -- есть легенда 
       ON par.partner_rk = leg.partner_rk 
 WHERE loc.partner_rk IS NULL; -- нет локации

7. У какого квеста (укажите его quest_nm) разница доли состоявшихся квестов в декабре 2022 и в январе 2023 наибольшая по модулю? Долей считать количество состоявшихся квестов деленное на количество заявленных. В случае наличия нескольких квестов, подходящих под условие, требуется вывести тот, у которого значение quest_rk больше. 
(Для выполнения этого задания тебе понадобится учебная БД и модель данных из лекции.)
- Реактивный восходящий тренд

SELECT q.quest_nm,
       proportion
  FROM
       (SELECT quest_rk,
               ABS(AVG(game_flg) FILTER(WHERE DATE_PART('year', game_dttm) = 2022 AND DATE_PART('month', game_dttm) = 12)
               - AVG(game_flg) FILTER(WHERE DATE_PART('year', game_dttm) = 2023 AND DATE_PART('month', game_dttm) = 01)) AS proportion
          FROM msu_analytics.Game AS g
         GROUP BY quest_rk) AS t
       LEFT JOIN msu_analytics.Quest AS q
       ON t.quest_rk = q.quest_rk
 WHERE proportion IS NOT NULL
 ORDER BY proportion DESC, t.quest_rk;

