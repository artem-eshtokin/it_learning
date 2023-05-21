-- Вставка записей
INSERT INTO de13an.XXXX_dwh_dim_terminals_hist (terminal_id, terminal_type, terminal_city, terminal_address, effective_from, effective_to, deleted_flg)
SELECT stg.terminal_id,
       stg.terminal_type,
       stg.terminal_city,
       stg.terminal_address,
       stg.dt_of_load,
       to_date( '3999-12-31', 'YYYY-MM-DD'),
       'N'       
  FROM de13an.XXXX_stg_terminals AS stg
       LEFT JOIN de13an.XXXX_dwh_dim_terminals_hist AS tgt
       ON stg.terminal_id = tgt.terminal_id
 WHERE tgt.terminal_id IS NULL;
-- Обновление предпоследней обновленной записи
UPDATE de13an.XXXX_dwh_dim_terminals_hist AS tgt
   SET effective_to = tmp.dt_of_load - INTERVAL '1 day'
  FROM (
        SELECT stg.terminal_id,
               stg.dt_of_load
          FROM de13an.XXXX_stg_terminals AS stg
               INNER JOIN de13an.XXXX_dwh_dim_terminals_hist AS tgt
               ON stg.terminal_id = tgt.terminal_id
                  AND tgt.effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
                  AND tgt.deleted_flg = 'N'
         WHERE 1=0
               OR (stg.terminal_id <> tgt.terminal_id) OR (stg.terminal_id IS NULL AND tgt.terminal_id IS NOT NULL) OR (stg.terminal_id IS NOT NULL AND tgt.terminal_id IS NULL)
               OR (stg.terminal_type <> tgt.terminal_type) OR (stg.terminal_type IS NULL AND tgt.terminal_type IS NOT NULL) OR (stg.terminal_type IS NOT NULL AND tgt.terminal_type IS NULL)
               OR (stg.terminal_city <> tgt.terminal_city) OR (stg.terminal_city IS NULL AND tgt.terminal_city IS NOT NULL) OR (stg.terminal_city IS NOT NULL AND tgt.terminal_city IS NULL)
               OR (stg.terminal_address <> tgt.terminal_address) OR (stg.terminal_address IS NULL AND tgt.terminal_address IS NOT NULL) OR (stg.terminal_address IS NOT NULL AND tgt.terminal_address IS NULL)
       ) AS tmp
 WHERE tgt.terminal_id = tmp.terminal_id
       AND tgt.effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' );
-- Вставка обновленных записей
INSERT INTO de13an.XXXX_dwh_dim_terminals_hist (terminal_id, terminal_type, terminal_city, terminal_address, effective_from, effective_to, deleted_flg)
SELECT stg.terminal_id,
       stg.terminal_type,
       stg.terminal_city,
       stg.terminal_address,
       stg.dt_of_load,
       to_date( '3999-12-31', 'YYYY-MM-DD'),
       'N'
  FROM de13an.XXXX_stg_terminals AS stg
       INNER JOIN de13an.XXXX_dwh_dim_terminals_hist AS tgt
       ON stg.terminal_id = tgt.terminal_id
          AND tgt.effective_to = stg.dt_of_load - INTERVAL '1 day'
          AND tgt.deleted_flg = 'N'
 WHERE 1=0
       OR (stg.terminal_id <> tgt.terminal_id) OR (stg.terminal_id IS NULL AND tgt.terminal_id IS NOT NULL) OR (stg.terminal_id IS NOT NULL AND tgt.terminal_id IS NULL)
       OR (stg.terminal_type <> tgt.terminal_type) OR (stg.terminal_type IS NULL AND tgt.terminal_type IS NOT NULL) OR (stg.terminal_type IS NOT NULL AND tgt.terminal_type IS NULL)
       OR (stg.terminal_city <> tgt.terminal_city) OR (stg.terminal_city IS NULL AND tgt.terminal_city IS NOT NULL) OR (stg.terminal_city IS NOT NULL AND tgt.terminal_city IS NULL)
       OR (stg.terminal_address <> tgt.terminal_address) OR (stg.terminal_address IS NULL AND tgt.terminal_address IS NOT NULL) OR (stg.terminal_address IS NOT NULL AND tgt.terminal_address IS NULL);
-- Вставка удаленной записи
INSERT INTO de13an.XXXX_dwh_dim_terminals_hist (terminal_id, terminal_type, terminal_city, terminal_address, effective_from, effective_to, deleted_flg)
SELECT 
       terminal_id,
       terminal_type,
       terminal_city,
       terminal_address,
       (
        SELECT MAX(dt_of_load)
          FROM de13an.XXXX_stg_terminals est
       ),
       TO_DATE( '3999-12-31', 'YYYY-MM-DD'),
       'Y'
  FROM de13an.XXXX_dwh_dim_terminals_hist
 WHERE terminal_id in (
                       SELECT tgt.terminal_id
                         FROM de13an.XXXX_dwh_dim_terminals_hist AS tgt
                              LEFT JOIN de13an.XXXX_stg_terminals AS stg
                              ON stg.terminal_id = tgt.terminal_id
                                 AND tgt.deleted_flg = 'N'
                       WHERE stg.terminal_id IS NULL
                      )
       AND effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
       AND deleted_flg = 'N';
-- Обновление предпоследней удаленной записи
UPDATE de13an.XXXX_dwh_dim_terminals_hist
   SET effective_to = (
        SELECT MAX(dt_of_load)
          FROM de13an.XXXX_stg_terminals est
       ) - INTERVAL '1 day'
 WHERE terminal_id IN (
                       SELECT tgt.terminal_id
                         FROM de13an.XXXX_dwh_dim_terminals_hist AS tgt
                              LEFT JOIN de13an.XXXX_stg_terminals AS stg
                              ON stg.terminal_id = tgt.terminal_id
                                 AND tgt.deleted_flg = 'N'
                        WHERE stg.terminal_id IS NULL
                      )
       AND effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
       AND deleted_flg = 'N';