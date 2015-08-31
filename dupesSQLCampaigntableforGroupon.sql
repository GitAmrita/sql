SELECT COUNT(groupon_deal_id),groupon_deal_id
 FROM groupon_campaign GROUP BY groupon_deal_id HAVING COUNT(groupon_deal_id)>3
 
 SELECT * FROM dbo.groupon_campaign
 WHERE groupon_deal_id ='canvas-on-demand-115-wilmington-newark'
 
SELECT gc1.groupon_deal_id_custom,  gc2.groupon_deal_id_custom,  gc1.groupon_campaign_id
 FROM dbo.groupon_campaign gc1
 JOIN groupon_campaign gc2 ON SUBSTRING(gc1.groupon_deal_id_custom, 1, LEN(gc1.groupon_deal_id_custom) - 2) = SUBSTRING(gc2.groupon_deal_id_custom, 1, LEN(gc2.groupon_deal_id_custom) - 2)
 AND gc1.groupon_deal_id_custom != gc2.groupon_deal_id_custom
 WHERE SUBSTRING(gc1.groupon_deal_id_custom, LEN(gc1.groupon_deal_id_custom) - 1, 2) = '00'
 

 