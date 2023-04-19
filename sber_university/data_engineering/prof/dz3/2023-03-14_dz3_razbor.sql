WITH ip AS (
			SELECT
				SUBSTR( data, 1, STRPOS( data, CHR(9) ) - 1 ) ip,
				SUBSTR( data, STRPOS( data, CHR(9) ) + 1 ) region
			FROM de.ip
		   ), 
     log AS (
			SELECT
				   ip,
				   field1,
				   field2,
				   dt,
				   link,
				   field3,
				   field3,
				   SUBSTR( data, 1, STRPOS( data, '/' ) - 1 ) browser,
				   data useragent
			  FROM (
					SELECT 
						   ip,
						   field1,
						   field2,
						   dt,
						   link,
						   field3,
						   SUBSTR( data, 1, STRPOS( data, CHR(9) ) - 1 ) field4,
						   SUBSTR( data, STRPOS( data, CHR(9) ) + 1 ) data
					  FROM (
							SELECT
								   ip,
								   field1,
								   field2,
								   dt,
								   link,
								   SUBSTR( data, 1, STRPOS( data, CHR(9) ) - 1 ) field3,
								   SUBSTR( data, STRPOS( data, CHR(9) ) + 1 ) data
							  FROM (
									SELECT 
										   ip,
										   field1,
										   field2,
										   dt,
										   SUBSTR( data, 1, STRPOS( data, CHR(9) ) - 1 ) link,
										   SUBSTR( data, STRPOS( data, CHR(9) ) + 1 ) data
									  FROM (
											SELECT 
												   ip,
												   field1,
												   field2,
												   TO_TIMESTAMP( SUBSTR( data, 1, STRPOS( data, CHR(9) ) - 1 ), 'YYYYMMDDHH24MISS' ) dt,
												   SUBSTR( data, STRPOS( data, CHR(9) ) + 1 ) data
											  FROM (
													SELECT 
														   ip,
														   field1,
														   SUBSTR( data, 1, STRPOS( data, CHR(9) ) - 1 ) field2,
														   SUBSTR( data, STRPOS( data, CHR(9) ) + 1 ) data
													  FROM (
															SELECT
																   ip,
																   SUBSTR( data, 1, STRPOS( data, CHR(9) ) - 1 ) field1,
																   SUBSTR( data, STRPOS( data, CHR(9) ) + 1 ) data
															  FROM (
																	SELECT
																		   SUBSTR( data, 1, STRPOS( data, CHR(9) ) - 1 ) ip,
																		   SUBSTR( data, STRPOS( data, CHR(9) ) + 1 ) data
																	  FROM de.log
																	) t
															) t
													) t
											) t
									) t
							) t
					) t
            ), 
     XXXX_log AS (
				  SELECT
				  		 CAST( dt AS date ) dt,
				  		 link,
				  		 useragent,
				  		 region,
				  		 browser
				    FROM log
				         LEFT JOIN ip
				         ON log.ip = ip.ip
				), 
     cnt_browsers AS (
					  SELECT 
					  		 region,
					  		 browser,
					  		 COUNT(*) cnt
					    FROM XXXX_log
					   GROUP BY region, browser
    				  ), 
     max_browsers AS (
					  SELECT
					  		 region,
					  		 MAX( cnt ) max_cnt
					    FROM cnt_browsers
					   GROUP BY region
					  )
SELECT
       m.region,
       c.browser
  FROM max_browsers AS m
       LEFT JOIN cnt_browsers AS c
       ON m.region = c.region
          AND m.max_cnt = c.cnt
 ORDER BY m.region;