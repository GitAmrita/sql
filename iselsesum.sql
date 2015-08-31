SELECT  lis.cup_user AS reviewer
, create_date_skey
, count(*) as total
, sum(case when image_status_no = 1 then 1 else 0 end ) as passed_total
, sum(case when image_status_no = -1 then 1 else 0 end ) as pended_total
FROM    log_image_status lis
where lis.cup_user is not null
group by lis.cup_user, create_date_skey
order by lis.cup_user, create_date_skey


