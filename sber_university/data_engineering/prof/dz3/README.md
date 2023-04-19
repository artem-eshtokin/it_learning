# ДЗ 3 - очистка данных

## Задание:
На основании таблиц DE.LOG и DE.IP постройте структурированную таблицу посещений DE13AN.XXXX_LOG ( DT DATE, LINK VARCHAR( 50 ), USER_AGENT VARCHAR( 200 ), REGION VARCHAR( 30 ) ). Также постройте отчет DE13AN.XXXX_LOG_REPORT (
REGION VARCHAR( 30 ), BROWSER VARCHAR( 10 ) ) – в каких областях какой браузер является наиболее используемым.

Просьба быть внимательным к названиям таблиц и полей – проверка полуавтоматическая. Под USER_AGENT подразумевается вся строка описания клиента, под BROWSER – только название браузера (Opera, Safari…). XXXX означает ваши 4 уникальные буквы.

На сервере должны быть созданы и наполнены данными таблицы, в classroom надо прислать файл с SQL кодом их создания.

Важные замечания (вплоть до причины незачета задания):
- Не используйте регулярные выражения там, где можно обойтись без них.
- То, что вы видите в выводе клиента – это не всегда именно то,что содержится в базе данных.

## Решение:
- Файлы create_de.log.sql и create_de.ip.sql краткая выдержка (10 строк) из учебной базы, для понимания формат предоставленных данных.
- 2023-03-02_dz3.sql - самостоятельное решение без регулярных выражений, но сложно читаемый код замены - сложно поддерживаемый случай.
- 2023-03-14_dz3_razbor.sql - разбор решения ДЗ с преподавателем - через вложенные запросы, best practice.