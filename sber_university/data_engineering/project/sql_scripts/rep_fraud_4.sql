WITH lag_table AS (
     SELECT card_num,
            trans_date,
            oper_type,
            oper_result,
            amt,
            LAG(oper_result, 1) OVER (PARTITION BY card_num ORDER BY trans_date) AS pr_res_1,
            LAG(amt, 1) OVER (PARTITION BY card_num ORDER BY trans_date) AS pr_amt_1,
            LAG(oper_result, 2) OVER (PARTITION BY card_num ORDER BY trans_date) AS pr_res_2,
            LAG(amt, 2) OVER (PARTITION BY card_num ORDER BY trans_date) AS pr_amt_2,
            LAG(oper_result, 3) OVER (PARTITION BY card_num ORDER BY trans_date) AS pr_res_3,
            LAG(amt, 3) OVER (PARTITION BY card_num ORDER BY trans_date) AS pr_amt_3,
            LAG(trans_date, 3) OVER (PARTITION BY card_num ORDER BY trans_date) AS pr_dt_3
       FROM
            de13an.XXXX_dwh_fact_transactions
                  ),
fraud_table AS (
     SELECT card_num,
            trans_date
       FROM lag_table
      WHERE oper_result = 'SUCCESS'
            AND amt < pr_amt_1
            AND pr_res_1 = 'REJECT'
            AND pr_amt_1 < pr_amt_2
            AND pr_res_2 = 'REJECT'
            AND pr_amt_2 < pr_amt_3
            AND pr_res_3 = 'REJECT'
            AND (trans_date - pr_dt_3) <= INTERVAL '20 minutes'
               )
INSERT INTO de13an.XXXX_rep_fraud (event_dt, passport, fio, phone, event_type, report_dt)
SELECT trans.trans_date,
       cli.passport_num,
       cli.last_name || ' ' || cli.first_name || ' ' || cli.patronymic,
       cli.phone,
       4,
       (SELECT MAX(last_update_dt) FROM de13an.XXXX_meta_source_file)
  FROM fraud_table AS trans
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