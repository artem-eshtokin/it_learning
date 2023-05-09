/*
-- БЛОК DDL

-- СОЗДАНИЕ

-- 1. Таблица источник
CREATE TABLE de13an.XXXX_source( 
	id INTEGER,
	val VARCHAR(50),
	update_dt TIMESTAMP(0)
);

-- 2. Таблица Stage
CREATE TABLE de13an.XXXX_stg( 
	id INTEGER,
	val VARCHAR(50),
	update_dt TIMESTAMP(0)
);

-- 3. Таблица Stage del
CREATE TABLE de13an.XXXX_stg_del ( 
	id INTEGER
);

-- 3. Таблица Target SCD2
CREATE TABLE de13an.XXXX_target_scd2 (
	id INTEGER,
	val VARCHAR(50),
	start_dt TIMESTAMP(0),
	end_dt TIMESTAMP(0),
	delete_flag CHAR(1)
);

-- 4. Таблица метаданных
CREATE TABLE de13an.XXXX_meta (
	schema_name VARCHAR(50),
	table_name VARCHAR(50),
	max_update_dt TIMESTAMP(0)
);
*/

/*
-- ОЧИСТКА (для отладки)

TRUNCATE TABLE de13an.XXXX_source;
TRUNCATE TABLE de13an.XXXX_stg;
TRUNCATE TABLE de13an.XXXX_stg_del;
TRUNCATE TABLE de13an.XXXX_target_scd2;
TRUNCATE TABLE de13an.XXXX_meta;
*/

-- Быстрый просмотр

SELECT *
  FROM de13an.XXXX_source
 ORDER BY 1;

SELECT *
  FROM de13an.XXXX_stg
 ORDER BY 1;

SELECT *
  FROM de13an.XXXX_stg_del
 ORDER BY 1;

SELECT *
  FROM de13an.XXXX_target_scd2
 ORDER BY 1, 4;

SELECT *
  FROM de13an.XXXX_meta;


-- НАПОЛНЕНИЕ

-- Шаг 0 (первичная загрузка)
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 1, 'A', now() );
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 2, 'B', now() );
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 3, 'C', now() );

INSERT INTO de13an.XXXX_meta (schema_name, table_name, max_update_dt)
VALUES ('de13an', 'XXXX_source', '1899-01-01 00:00:00');


-- Шаг 1 (добавление новых записей)
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 4, 'D', now() );
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 5, 'E', now() );

-- Шаг 2 (добавление и изменение записей)
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 6, 'F', now() );
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 7, 'G', now() );

UPDATE de13an.XXXX_source
   SET val = 'MMM', update_dt = now()
 WHERE id IN (3, 4);

-- Шаг 3 (добавление и повторное изменение записей)
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 8, 'H', now() );
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 9, 'I', now() );

UPDATE de13an.XXXX_source
   SET val = 'RRR', update_dt = now()
 WHERE id IN (3, 4, 5, 6);

-- Шаг 4 (добавление, изменение, удаление)
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 10, 'L', now() );
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 11, 'M', now() );
INSERT INTO de13an.XXXX_source ( id, val, update_dt ) VALUES ( 12, 'N', now() );

UPDATE de13an.XXXX_source
   SET val = 'SSS', update_dt = now()
 WHERE id IN (4, 6, 8);

DELETE
  FROM de13an.XXXX_source
 WHERE id IN (1, 3);


-- КОД СКРИПТА ИНКРЕМЕНТАЛЬНОЙ ЗАГРУЗКА SCD2

-- 1. Очистка stg таблиц
TRUNCATE TABLE de13an.XXXX_stg;
TRUNCATE TABLE de13an.XXXX_stg_del;


-- 2. Захват данных из источника в stg
INSERT INTO de13an.XXXX_stg ( id, val, update_dt )
SELECT id,
       val,
       update_dt
  FROM de13an.XXXX_source
 WHERE update_dt > (
				    SELECT max_update_dt
				      FROM de13an.XXXX_meta
				     WHERE schema_name = 'de13an'
				           AND table_name = 'XXXX_source'
				   );


-- 3. Захват данных из источника в stg_del
INSERT INTO de13an.XXXX_stg_del ( id )
SELECT id
  FROM de13an.XXXX_source;


-- 4. Загрузка новых записей в детальный слой
INSERT INTO de13an.XXXX_target_scd2 ( id, val, start_dt, end_dt, delete_flag )
SELECT 
	   stg.id,
	   stg.val,
	   stg.update_dt,
	   '3999-12-31',
	   'N'
  FROM de13an.XXXX_stg AS stg
       LEFT JOIN de13an.XXXX_target_scd2 AS tgt
       ON stg.id = tgt.id
  WHERE tgt.id IS NULL;


-- 5. Изменение "предпоследних" записей
UPDATE de13an.XXXX_target_scd2 AS tgt
   SET 
	   end_dt = t.update_dt - INTERVAL '1 second'
  FROM (
	    SELECT 
		       stg.id,
		       stg.update_dt,
		       MAX(start_dt) AS max_start_dt
	      FROM de13an.XXXX_stg AS stg
	           LEFT JOIN de13an.XXXX_target_scd2 AS tgt
	           ON stg.id = tgt.id
	     WHERE 1=0
		       OR (stg.val <> tgt.val) OR (stg.val IS NULL AND tgt.val IS NOT NULL) OR (stg.val IS NOT NULL AND tgt.val IS NULL)
		 GROUP BY stg.id, stg.update_dt
       ) AS t
 WHERE tgt.id = t.id
       AND tgt.start_dt = t.max_start_dt;


-- 6. Загрузка актуальных записей в детальный слой
INSERT INTO de13an.XXXX_target_scd2 ( id, val, start_dt, end_dt, delete_flag )
SELECT 
	   stg.id,
	   stg.val,
	   stg.update_dt,
	   '3999-12-31',
	   'N'
  FROM de13an.XXXX_stg AS stg
       LEFT JOIN de13an.XXXX_target_scd2 AS tgt
       ON stg.id = tgt.id
 WHERE 1=0
	   OR (stg.val <> tgt.val) OR (stg.val IS NULL AND tgt.val IS NOT NULL) OR (stg.val IS NOT NULL AND tgt.val IS NULL)
 GROUP BY stg.id, stg.val, stg.update_dt;


-- 7. Изменение записи перед удалением.
UPDATE de13an.XXXX_target_scd2 AS tgt
   SET 
	   end_dt = now()
 WHERE end_dt = TO_DATE( '3999-12-31', 'YYYY-MM-DD' )
       AND id IN (
	              SELECT 
		                 tgt.id
	                FROM de13an.XXXX_target_scd2 AS tgt
	                     LEFT JOIN de13an.XXXX_stg_del AS stg
	                     ON stg.id = tgt.id
	               WHERE stg.id IS NULL
             );


-- 8. Отметка об удалении
INSERT INTO de13an.XXXX_target_scd2 ( id, val, start_dt, end_dt, delete_flag )
SELECT
       id,
       val,
       end_dt + INTERVAL '1 second',
       '3999-12-31',
       'Y'
  FROM de13an.XXXX_target_scd2
 WHERE (id, end_dt) IN (
	              SELECT 
		                 tgt.id,
		                 MAX(end_dt) AS max_end_dt
	                FROM de13an.XXXX_target_scd2 AS tgt
	                     LEFT JOIN de13an.XXXX_stg_del AS stg
	                     ON stg.id = tgt.id
	               WHERE stg.id IS NULL
	               GROUP BY tgt.id
	              );


-- 9. Обновление метаданных.
UPDATE de13an.XXXX_meta AS tgt
   SET max_update_dt = COALESCE( (SELECT MAX(update_dt) FROM de13an.XXXX_stg), tgt.max_update_dt )
 WHERE schema_name = 'de13an'
       AND table_name = 'XXXX_source';

-- 10. Фиксация изменений.
COMMIT;
