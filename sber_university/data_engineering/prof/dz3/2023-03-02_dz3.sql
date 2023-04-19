CREATE TABLE de13an.XXXX_log (
       DT DATE,
       LINK VARCHAR(50),
       USER_AGENT VARCHAR(200),
       REGION VARCHAR(30)
       );

INSERT INTO de13an.XXXX_log (DT, LINK, USER_AGENT, REGION)
SELECT TO_DATE(SUBSTR(l.data, STRPOS(l.data, CHR(9) || CHR(9) || CHR(9)) + 3, 8), 'YYYYMMDD') AS dt,
       SUBSTR(l.data, STRPOS(l.data, 'http'), STRPOS(SUBSTR(l.data, STRPOS(l.data, 'http')), CHR(9)) - 1) AS link,
       TRIM(REPLACE(SUBSTR(SUBSTR(SUBSTR(SUBSTR(l.data, STRPOS(l.data, 'http')), STRPOS(SUBSTR(l.data, STRPOS(l.data, 'http')), CHR(9)) + 1), STRPOS(SUBSTR(SUBSTR(l.data, STRPOS(l.data, 'http')), STRPOS(SUBSTR(l.data, STRPOS(l.data, 'http')), CHR(9)) + 1), CHR(9)) + 1),
                           STRPOS(SUBSTR(SUBSTR(SUBSTR(l.data, STRPOS(l.data, 'http')), STRPOS(SUBSTR(l.data, STRPOS(l.data, 'http')), CHR(9)) + 1), STRPOS(SUBSTR(SUBSTR(l.data, STRPOS(l.data, 'http')), STRPOS(SUBSTR(l.data, STRPOS(l.data, 'http')), CHR(9)) + 1), CHR(9)) + 1), CHR(9)) + 1) || '-=-+',
                   'n-=-+', '')) AS user_agent,
       SUBSTR(i.data, STRPOS(i.data, CHR(9))+1) AS region
  FROM de.log AS l
       LEFT JOIN de.ip AS i 
       ON SUBSTR(l.data, 1, STRPOS(l.data, CHR(9))-1) = SUBSTR(i.data, 1, STRPOS(i.data, CHR(9))-1)
 WHERE l.data IS NOT NULL;

SELECT *
  FROM de13an.XXXX_log;

CREATE TABLE de13an.XXXX_log_report (
       REGION VARCHAR(30),
       BROWSER VARCHAR(10)
       );

INSERT INTO de13an.XXXX_log_report (REGION, BROWSER)
WITH t1 AS (
            SELECT region,
                   SUBSTR(user_agent, 1, STRPOS(user_agent, '/')-1) AS browser,
                   COUNT(*) AS cnt
              FROM de13an.XXXX_log AS el
             GROUP BY region, SUBSTR(user_agent, 1, STRPOS(user_agent, '/')-1)
           ),
     t2 AS (
            SELECT region,
                   MAX(cnt) AS max_cnt
              FROM t1
             GROUP BY region
           )
SELECT t1.region,
       t1.browser
  FROM t1
       INNER JOIN t2
       ON t1.region = t2.region
          AND t1.cnt = t2.max_cnt;

SELECT *
  FROM de13an.XXXX_log_report;