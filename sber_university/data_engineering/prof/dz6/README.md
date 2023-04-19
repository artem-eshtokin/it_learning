# ДЗ 6 - соединение фактовой и SCD2 таблицы

## Задание:
Создайте таблицу DE13AN.XXXX_SALARY_HIST, где XXXX - ваш идентификатор. В таблице должна быть SCD2 версия таблицы DE.HISTGROUP (поля PERSON, CLASS, SALARY, EFFECTIVE_FROM, EFFECTIVE_TO). Возьмите в работу таблицы DE13AN.XXXX_SALARY_HIST и DE.SALARY_PAYMENTS. Напишите SQL скрипт, выводящий таблицу платежей сотрудникам. В таблице должны быть поля PAYMENT_DT, PERSON, PAYMENT, MONTH_PAID, MONTH_REST. Результат выполнения сохраните в таблицу DE13AN.XXXX_SALARY_LOG.

MONTH_PAID - суммарно выплачено в месяце,
MONTH_REST - осталось выплатить за месяц.

Проверяется в первую очередь понимание как соединять фактовую таблицу с SCD2 таблицей (нельзя все расчеты сделать над DE.SALARY_PAYMENTS, ведь работнику могут недоплатить или переплатить).

В ответе приложите SQL скрипт, таблица DE13AN.XXXX_SALARY_LOG должна быть заполнена.

## Решение:
- de.histgroup.csv и de.salary_payments.csv - таблицы источники.
- 2023-04-10_dz6.sql - скрипт решения.