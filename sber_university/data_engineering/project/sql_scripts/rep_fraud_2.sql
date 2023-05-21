INSERT INTO de13an.XXXX_rep_fraud (event_dt, passport, fio, phone, event_type, report_dt)
SELECT trans.trans_date,
       cli.passport_num,
       cli.last_name || ' ' || cli.first_name || ' ' || cli.patronymic,
       cli.phone,
       2,
       (SELECT MAX(last_update_dt) FROM de13an.XXXX_meta_source_file)
  FROM de13an.XXXX_dwh_fact_transactions AS trans
       LEFT JOIN de13an.XXXX_dwh_dim_cards_hist AS cards
       ON trans.card_num = cards.card_num 
          AND cards.effective_to = TO_DATE( '3999-12-31', 'YYYY-MM-DD')
          AND cards.deleted_flg = 'N'
       LEFT JOIN de13an.XXXX_dwh_dim_accounts_hist AS acc
       ON cards.account_num = acc.account_num
          AND acc.effective_to = TO_DATE( '3999-12-31', 'YYYY-MM-DD')
          AND acc.deleted_flg = 'N'
       LEFT JOIN de13an.XXXX_dwh_dim_clients_hist cli
       ON acc.client = cli.client_id
          AND cli.effective_to = TO_DATE( '3999-12-31', 'YYYY-MM-DD')
          AND cli.deleted_flg = 'N'
 WHERE CAST(trans.trans_date AS DATE) = (SELECT MAX(last_update_dt) FROM de13an.XXXX_meta_source_file)
       AND CAST(trans.trans_date AS DATE) > acc.valid_to