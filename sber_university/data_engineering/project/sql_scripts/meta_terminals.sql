UPDATE de13an.XXXX_meta_source_file AS mt
   SET last_update_dt = COALESCE( (SELECT MAX(dt_of_load) FROM de13an.XXXX_stg_terminals), mt.last_update_dt ),
       error_days_count = 0
 WHERE file_name = 'terminals';