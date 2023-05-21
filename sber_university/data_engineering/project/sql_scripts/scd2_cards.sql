-- Вставка записей
INSERT INTO de13an.XXXX_dwh_dim_cards_hist (card_num, account_num, effective_from, effective_to, deleted_flg)
SELECT 
       stg.card_num,
       stg.account_num,
       COALESCE(stg.update_dt, stg.create_dt),
       to_date( '3999-12-31', 'YYYY-MM-DD'),
       'N'       
  FROM de13an.XXXX_stg_cards AS stg
       LEFT JOIN de13an.XXXX_dwh_dim_cards_hist AS tgt
       ON stg.card_num = tgt.card_num
 WHERE tgt.card_num IS NULL;
-- Обновление предпоследней обновленной записи
UPDATE de13an.XXXX_dwh_dim_cards_hist AS tgt
   SET effective_to = tmp.dt - INTERVAL '1 day'
  FROM (
        SELECT stg.card_num,
               COALESCE(stg.update_dt, stg.create_dt) AS dt
          FROM de13an.XXXX_stg_cards AS stg
               INNER JOIN de13an.XXXX_dwh_dim_cards_hist AS tgt
               ON stg.card_num = tgt.card_num
                  AND tgt.effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
                  AND tgt.deleted_flg = 'N'
         WHERE 1=0
               OR (stg.card_num <> tgt.card_num) OR (stg.card_num IS NULL AND tgt.card_num IS NOT NULL) OR (stg.card_num IS NOT NULL AND tgt.card_num IS NULL)
               OR (stg.account_num <> tgt.account_num) OR (stg.account_num IS NULL AND tgt.account_num IS NOT NULL) OR (stg.account_num IS NOT NULL AND tgt.account_num IS NULL)
       ) AS tmp
 WHERE tgt.card_num = tmp.card_num
       AND tgt.effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' );
-- Вставка обновленных записей
INSERT INTO de13an.XXXX_dwh_dim_cards_hist (card_num, account_num, effective_from, effective_to, deleted_flg)
SELECT stg.card_num,
       stg.account_num,
       COALESCE(stg.update_dt, stg.create_dt),
       to_date( '3999-12-31', 'YYYY-MM-DD'),
       'N'
  FROM de13an.XXXX_stg_cards AS stg
       INNER JOIN de13an.XXXX_dwh_dim_cards_hist AS tgt
       ON stg.card_num = tgt.card_num
          AND tgt.effective_to = COALESCE(stg.update_dt, stg.create_dt) - INTERVAL '1 day'
          AND tgt.deleted_flg = 'N'
 WHERE 1=0
       OR (stg.card_num <> tgt.card_num) OR (stg.card_num IS NULL AND tgt.card_num IS NOT NULL) OR (stg.card_num IS NOT NULL AND tgt.card_num IS NULL)
       OR (stg.account_num <> tgt.account_num) OR (stg.account_num IS NULL AND tgt.account_num IS NOT NULL) OR (stg.account_num IS NOT NULL AND tgt.account_num IS NULL);
-- Вставка удаленной записи
INSERT INTO de13an.XXXX_dwh_dim_cards_hist (card_num, account_num, effective_from, effective_to, deleted_flg)
SELECT 
       card_num,
       account_num,
       CAST(NOW() AS DATE),
       TO_DATE( '3999-12-31', 'YYYY-MM-DD'),
       'Y'
  FROM de13an.XXXX_dwh_dim_cards_hist
 WHERE card_num in (
                    SELECT tgt.card_num
                      FROM de13an.XXXX_dwh_dim_cards_hist AS tgt
                           LEFT JOIN de13an.XXXX_stg_del_cards AS stg
                           ON stg.card_num = tgt.card_num
                              AND tgt.deleted_flg = 'N'
                     WHERE stg.card_num IS NULL
                   )
       AND effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
       AND deleted_flg = 'N';
-- Обновление предпоследней удаленной записи
UPDATE de13an.XXXX_dwh_dim_cards_hist
   SET effective_to = CAST(NOW() AS DATE) - INTERVAL '1 day'
 WHERE card_num IN (
                    SELECT tgt.card_num
                      FROM de13an.XXXX_dwh_dim_cards_hist AS tgt
                           LEFT JOIN de13an.XXXX_stg_del_cards AS stg
                           ON stg.card_num = tgt.card_num
                              AND tgt.deleted_flg = 'N'
                     WHERE stg.card_num IS NULL
                    )
       AND effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
       AND deleted_flg = 'N';