-- Вставка записей
INSERT INTO de13an.XXXX_dwh_dim_clients_hist (client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, effective_from, effective_to, deleted_flg)
SELECT 
       stg.client_id,
       stg.last_name,
       stg.first_name,
       stg.patronymic,
       stg.date_of_birth,
       stg.passport_num,
       stg.passport_valid_to,
       stg.phone,
       COALESCE(stg.update_dt, stg.create_dt),
       to_date( '3999-12-31', 'YYYY-MM-DD'),
       'N'
  FROM de13an.XXXX_stg_clients AS stg
       LEFT JOIN de13an.XXXX_dwh_dim_clients_hist AS tgt
       ON stg.client_id = tgt.client_id
 WHERE tgt.client_id IS NULL;
-- Обновление предпоследней обновленной записи
UPDATE de13an.XXXX_dwh_dim_clients_hist AS tgt
   SET effective_to = tmp.dt - INTERVAL '1 day'
  FROM (
        SELECT stg.client_id,
               COALESCE(stg.update_dt, stg.create_dt) AS dt
          FROM de13an.XXXX_stg_clients AS stg
               INNER JOIN de13an.XXXX_dwh_dim_clients_hist AS tgt
               ON stg.client_id = tgt.client_id
                  AND tgt.effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
                  AND tgt.deleted_flg = 'N'
         WHERE 1=0
               OR (stg.client_id <> tgt.client_id) OR (stg.client_id IS NULL AND tgt.client_id IS NOT NULL) OR (stg.client_id IS NOT NULL AND tgt.client_id IS NULL)
               OR (stg.last_name <> tgt.last_name) OR (stg.last_name IS NULL AND tgt.last_name IS NOT NULL) OR (stg.last_name IS NOT NULL AND tgt.last_name IS NULL)
               OR (stg.first_name <> tgt.first_name) OR (stg.first_name IS NULL AND tgt.first_name IS NOT NULL) OR (stg.first_name IS NOT NULL AND tgt.first_name IS NULL)
               OR (stg.patronymic <> tgt.patronymic) OR (stg.patronymic IS NULL AND tgt.patronymic IS NOT NULL) OR (stg.patronymic IS NOT NULL AND tgt.patronymic IS NULL)
               OR (stg.date_of_birth <> tgt.date_of_birth) OR (stg.date_of_birth IS NULL AND tgt.date_of_birth IS NOT NULL) OR (stg.date_of_birth IS NOT NULL AND tgt.date_of_birth IS NULL)
               OR (stg.passport_num <> tgt.passport_num) OR (stg.passport_num IS NULL AND tgt.passport_num IS NOT NULL) OR (stg.passport_num IS NOT NULL AND tgt.passport_num IS NULL)
               OR (stg.passport_valid_to <> tgt.passport_valid_to) OR (stg.passport_valid_to IS NULL AND tgt.passport_valid_to IS NOT NULL) OR (stg.passport_valid_to IS NOT NULL AND tgt.passport_valid_to IS NULL)
               OR (stg.phone <> tgt.phone) OR (stg.phone IS NULL AND tgt.phone IS NOT NULL) OR (stg.phone IS NOT NULL AND tgt.phone IS NULL)
       ) AS tmp
 WHERE tgt.client_id = tmp.client_id
       AND tgt.effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' );
-- Вставка обновленных записей
INSERT INTO de13an.XXXX_dwh_dim_clients_hist (client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, effective_from, effective_to, deleted_flg)
SELECT stg.client_id,
       stg.last_name,
       stg.first_name,
       stg.patronymic,
       stg.date_of_birth,
       stg.passport_num,
       stg.passport_valid_to,
       stg.phone,
       COALESCE(stg.update_dt, stg.create_dt),
       to_date( '3999-12-31', 'YYYY-MM-DD'),
       'N'
  FROM de13an.XXXX_stg_clients AS stg
       INNER JOIN de13an.XXXX_dwh_dim_clients_hist AS tgt
       ON stg.client_id = tgt.client_id
          AND tgt.effective_to = COALESCE(stg.update_dt, stg.create_dt) - INTERVAL '1 day'
          AND tgt.deleted_flg = 'N'
 WHERE 1=0
       OR (stg.client_id <> tgt.client_id) OR (stg.client_id IS NULL AND tgt.client_id IS NOT NULL) OR (stg.client_id IS NOT NULL AND tgt.client_id IS NULL)
       OR (stg.last_name <> tgt.last_name) OR (stg.last_name IS NULL AND tgt.last_name IS NOT NULL) OR (stg.last_name IS NOT NULL AND tgt.last_name IS NULL)
       OR (stg.first_name <> tgt.first_name) OR (stg.first_name IS NULL AND tgt.first_name IS NOT NULL) OR (stg.first_name IS NOT NULL AND tgt.first_name IS NULL)
       OR (stg.patronymic <> tgt.patronymic) OR (stg.patronymic IS NULL AND tgt.patronymic IS NOT NULL) OR (stg.patronymic IS NOT NULL AND tgt.patronymic IS NULL)
       OR (stg.date_of_birth <> tgt.date_of_birth) OR (stg.date_of_birth IS NULL AND tgt.date_of_birth IS NOT NULL) OR (stg.date_of_birth IS NOT NULL AND tgt.date_of_birth IS NULL)
       OR (stg.passport_num <> tgt.passport_num) OR (stg.passport_num IS NULL AND tgt.passport_num IS NOT NULL) OR (stg.passport_num IS NOT NULL AND tgt.passport_num IS NULL)
       OR (stg.passport_valid_to <> tgt.passport_valid_to) OR (stg.passport_valid_to IS NULL AND tgt.passport_valid_to IS NOT NULL) OR (stg.passport_valid_to IS NOT NULL AND tgt.passport_valid_to IS NULL)
       OR (stg.phone <> tgt.phone) OR (stg.phone IS NULL AND tgt.phone IS NOT NULL) OR (stg.phone IS NOT NULL AND tgt.phone IS NULL);
-- Вставка удаленной записи
INSERT INTO de13an.XXXX_dwh_dim_clients_hist (client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, effective_from, effective_to, deleted_flg)
SELECT client_id,
       last_name,
       first_name,
       patronymic,
       date_of_birth,
       passport_num,
       passport_valid_to,
       phone,
       CAST(NOW() AS DATE),
       TO_DATE( '3999-12-31', 'YYYY-MM-DD'),
       'Y'
  FROM de13an.XXXX_dwh_dim_clients_hist
 WHERE client_id in (
                    SELECT tgt.client_id
                      FROM de13an.XXXX_dwh_dim_clients_hist AS tgt
                           LEFT JOIN de13an.XXXX_stg_del_clients AS stg
                           ON stg.client_id = tgt.client_id
                              AND tgt.deleted_flg = 'N'
                     WHERE stg.client_id IS NULL
                   )
       AND effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
       AND deleted_flg = 'N';
-- Обновление предпоследней удаленной записи
UPDATE de13an.XXXX_dwh_dim_clients_hist
   SET effective_to = CAST(NOW() AS DATE) - INTERVAL '1 day'
 WHERE client_id IN (
                    SELECT tgt.client_id
                      FROM de13an.XXXX_dwh_dim_clients_hist AS tgt
                           LEFT JOIN de13an.XXXX_stg_del_clients AS stg
                           ON stg.client_id = tgt.client_id
                              AND tgt.deleted_flg = 'N'
                     WHERE stg.client_id IS NULL
                    )
       AND effective_to = TO_DATE( '3999-12-31','YYYY-MM-DD' )
       AND deleted_flg = 'N';