SELECT sif.order_no ,
sif.company_skey
FROM dbo.salesitem_fact sif
JOIN dbo.salesorder_fact sof ON sif.salesorder_fact_skey = sof.salesorder_fact_skey
JOIN dbo.traffic_source_dim ts ON sif.traffic_source_skey = ts.traffic_source_skey
WHERE sif.company_skey = 3
AND ( ts.traffic_source_name NOT LIKE '%groupon~_%' ESCAPE '~'
AND ts.traffic_source_name NOT LIKE '%amazon%'
AND traffic_source_name NOT LIKE '%living%'
AND (traffic_source_name NOT LIKE '%shopsocial%' or traffic_source_name LIKE '%localshopsocially%')
AND traffic_source_name NOT LIKE '%google%'
AND traffic_source_name NOT LIKE '%plum%'
)
AND sif.groupon_fact_skey IS NULL
AND sof.order_no = 1443344
AND sof.charge_date_skey >= 105734
AND sif.order_no NOT IN ( SELECT DISTINCT
order_no
FROM dbo.salesitem_fact
WHERE groupon_fact_skey > 0
AND company_skey = 3 )
UNION 
SELECT axo.order_no
, 3 AS company_skey
FROM promotionDB..axready_override axo
WHERE axo.dw_lastupdate_date > GETDATE() - 3
