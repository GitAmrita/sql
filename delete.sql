create table #temp1(couponid int, offercode int)
create table #temp2(couponid int, offercode int)

insert into #temp1(couponid , offercode )
values(155343, 1000)
insert into #temp1(couponid , offercode )
values(155344, 2000)
insert into #temp2(couponid , offercode )
values(155345, 3000)
insert into #temp2(couponid , offercode )
values(155343, 1000)
insert into #temp1(couponid , offercode )
values(155346, 5000)
insert into #temp2(couponid , offercode )
values(155346, 1000)
select * from #temp1
select * from #temp2

delete #temp2
from #temp2 o
join (select couponid, offercode from #temp1) as r on o.couponid = r.couponid and o.offercode=r.offercode
