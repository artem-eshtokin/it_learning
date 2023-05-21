-- Вставка записей
INSERT INTO de13an.XXXX_dwh_dim_accounts_hist (account_num, valid_to, client, effective_from, effective_to, deleted_flg)
SELECT 
       stg.account_num,
       stg.valid_to,
       stg.client,
       COALESCE(stg.update_dt, stg.create_dt),
       to_date( '3999-12-31', 'YYYY-MM-DD'),
       'N'
  FROM de13an.XXXX_stg_accounts AS stg
       LEFT JOIN de13an.XXXX_dwh_dim_accounts_hist AS tgt
       ON stg.account_num = tgt.account_num
 WHERE tgt.account_num IS NULL;
-- Обновление предпоследней обновленной записи
UPDATE de13an.XXXX_dwh_dim_accounts_hist AS tgt
   SET effective_to = tmp.dt - INTERVAL '1 day'
  FROM (
        SELECT stg.account_num,
               COALESCE(stg.update_dt, stg.create_dt) AS dt
          FROM de13an.XXXX_stg_accounts AS stg
               INNER JOIN de13an.XXXX_dwh_dim_accounts_hist AS tgt
               ON stg.account_num = tgt.account_num
                  AND tgt.effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
                  AND tgt.deleted_flg = 'N'
         WHERE 1=0
               OR (stg.account_num <> tgt.account_num) OR (stg.account_num IS NULL AND tgt.account_num IS NOT NULL) OR (stg.account_num IS NOT NULL AND tgt.account_num IS NULL)
               OR (stg.valid_to <> tgt.valid_to) OR (stg.valid_to IS NULL AND tgt.valid_to IS NOT NULL) OR (stg.valid_to IS NOT NULL AND tgt.valid_to IS NULL)
               OR (stg.client <> tgt.client) OR (stg.client IS NULL AND tgt.client IS NOT NULL) OR (stg.client IS NOT NULL AND tgt.client IS NULL)
       ) AS tmp
 WHERE tgt.account_num = tmp.account_num
       AND tgt.effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' );
-- Вставка обновленных записей
INSERT INTO de13an.XXXX_dwh_dim_accounts_hist (account_num, valid_to, client, effective_from, effective_to, deleted_flg)
SELECT stg.account_num,
       stg.valid_to,
       stg.client,
       COALESCE(stg.update_dt, stg.create_dt),
       to_date( '3999-12-31', 'YYYY-MM-DD'),
       'N'
  FROM de13an.XXXX_stg_accounts AS stg
       INNER JOIN de13an.XXXX_dwh_dim_accounts_hist AS tgt
       ON stg.account_num = tgt.account_num
          AND tgt.effective_to = COALESCE(stg.update_dt, stg.create_dt) - INTERVAL '1 day'
          AND tgt.deleted_flg = 'N'
 WHERE 1=0
       OR (stg.account_num <> tgt.account_num) OR (stg.account_num IS NULL AND tgt.account_num IS NOT NULL) OR (stg.account_num IS NOT NULL AND tgt.account_num IS NULL)
       OR (stg.valid_to <> tgt.valid_to) OR (stg.valid_to IS NULL AND tgt.valid_to IS NOT NULL) OR (stg.valid_to IS NOT NULL AND tgt.valid_to IS NULL)
       OR (stg.client <> tgt.client) OR (stg.client IS NULL AND tgt.client IS NOT NULL) OR (stg.client IS NOT NULL AND tgt.client IS NULL);
-- Вставка удаленной записи
INSERT INTO de13an.XXXX_dwh_dim_accounts_hist (account_num, valid_to, client, effective_from, effective_to, deleted_flg)
SELECT account_num,
       valid_to,
       client,
       CAST(NOW() AS DATE),
       TO_DATE( '3999-12-31', 'YYYY-MM-DD'),
       'Y'
  FROM de13an.XXXX_dwh_dim_accounts_hist
 WHERE account_num in (
                    SELECT tgt.account_num
                      FROM de13an.XXXX_dwh_dim_accounts_hist AS tgt
                           LEFT JOIN de13an.XXXX_stg_del_accounts AS stg
                           ON stg.account_num = tgt.account_num
                              AND tgt.deleted_flg = 'N'
                     WHERE stg.account_num IS NULL
                   )
       AND effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
       AND deleted_flg = 'N';
-- Обновление предпоследней удаленной записи
UPDATE de13an.XXXX_dwh_dim_accounts_hist
   SET effective_to = CAST(NOW() AS DATE) - INTERVAL '1 day'
 WHERE account_num IN (
                    SELECT tgt.account_num
                      FROM de13an.XXXX_dwh_dim_accounts_hist AS tgt
                           LEFT JOIN de13an.XXXX_stg_del_accounts AS stg
                           ON stg.account_num = tgt.account_num
                              AND tgt.deleted_flg = 'N'
                     WHERE stg.account_num IS NULL
                    )
       AND effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
       AND deleted_flg = 'N';