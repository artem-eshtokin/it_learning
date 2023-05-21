WITH find_trans AS (
     SELECT trans_date, card_num
       FROM (
             SELECT 
                    trans_date,
                    card_num,
                    terminal_city,
                    LAG(trans_date) OVER (PARTITION BY card_num ORDER BY trans_date) AS prev_date,
                    LAG(terminal_city) OVER (PARTITION BY card_num ORDER BY trans_date) AS prev_city,
                    LEAD(terminal_city) OVER (PARTITION BY card_num ORDER BY trans_date) AS next_city
               FROM (
                     SELECT trans.trans_date,
                            trans.card_num,
                            term.terminal_city
                       FROM de13an.XXXX_dwh_fact_transactions AS trans
                            INNER JOIN de13an.XXXX_dwh_dim_terminals_hist AS term
                            ON trans.terminal = term.terminal_id 
                               AND term.effective_to = TO_DATE( '3999-12-31', 'YYYY-MM-DD')) t1
            ) t2
      WHERE
            prev_city IS NOT NULL 
            AND prev_city <> terminal_city 
            AND next_city <> terminal_city
            AND (trans_date - prev_date <= INTERVAL '1 hour')
                   )
INSERT INTO de13an.XXXX_rep_fraud (event_dt, passport, fio, phone, event_type, report_dt)
SELECT trans.trans_date,
       cli.passport_num,
       cli.last_name || ' ' || cli.first_name || ' ' || cli.patronymic,
       cli.phone,
       3,
       (SELECT MAX(last_update_dt) FROM de13an.XXXX_meta_source_file)
  FROM find_trans AS trans
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