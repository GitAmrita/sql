select a12.groupon_campaign_skey  ,
	sum(((((a11.line_sale_amt + a11.line_ship_amt) + a11.line_tax_amt) - a11.line_ord_cpn_disc_amt) + a11.groupon_price))  revenue_including_groupon,
	sum(a11.groupon_price)  groupon_revenue,a15.calendar_date as order_dt,a16.short_desc,a16.product_type_no,a17.calendar_date as offer_start_dt,
	count(distinct a11.order_no)  order_count

from	salesitem_fact	a11
	join	groupon_fact	a12
	  on 	(a11.groupon_fact_skey = a12.groupon_fact_skey)
	join	salesorder_fact	a13
	  on 	(a11.salesorder_fact_skey = a13.salesorder_fact_skey)
	join	groupon_campaign_dim	a14
	  on 	(a12.groupon_campaign_skey = a14.groupon_campaign_skey)
	join	date_dim	a15
	  on 	(a11.order_date_skey = a15.date_skey)
	join product_type_dim  a16 
		on a11.product_type_skey=a16.product_type_skey
	join	date_dim	a17
		on 	(a14.offer_start_date_skey = a17.date_skey)

where	(a13.order_status_skey in (7, 10, 5, 20, 11, 8, 14)
 and (not a13.payment_type_skey in (3, 4, 10))
 and a11.sale_source_skey not in (3, 2)
 and a14.groupon_site_skey in (1)
 and a15.calendar_date between '2012-06-01' and '2012-07-13')
group by	a12.groupon_campaign_skey ,a15.calendar_date,a16.short_desc,a16.product_type_no,a17.calendar_date
order by a15.calendar_date




