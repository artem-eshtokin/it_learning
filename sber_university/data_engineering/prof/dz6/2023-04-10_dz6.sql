# 2023-04-10 DZ6

CREATE TABLE de13an.XXXX_salary_hist AS
SELECT
       person,
       class,
       salary,
       dt AS effective_from,
       CAST(COALESCE(LEAD(dt) OVER(PARTITION BY person ORDER BY dt) - INTERVAL '1 DAY', TO_DATE('3999-12-31', 'YYYY-MM-DD') ) AS DATE) AS effective_to
  FROM de.histgroup;

CREATE TABLE de13an.XXXX_salary_log AS
SELECT 
       sp.dt AS payment_dt,
       sp.person,
       sp.payment,
       -- SUM(sp.payment) OVER (PARTITION BY sp.person, TO_CHAR(sp.dt, 'YYYY-MM') ORDER BY sp.dt) AS month_paid,
       SUM(sp.payment) OVER (PARTITION BY sp.person, (EXTRACT(MONTH FROM sp.dt) + EXTRACT(YEAR FROM sp.dt)*12) ORDER BY sp.dt) AS month_paid,
       xx.salary - SUM(sp.payment) OVER (PARTITION BY sp.person, (EXTRACT(MONTH FROM sp.dt) + EXTRACT(YEAR FROM sp.dt)*12) ORDER BY sp.dt) AS month_rest
  FROM de.salary_payments AS sp
       FULL JOIN de13an.XXXX_salary_hist AS xx
       ON sp.person = xx.person
          AND sp.dt BETWEEN xx.effective_from AND xx.effective_to;