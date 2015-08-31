create table #Tmp1 (ManID varchar(10), couponid int, ocr varchar(7), company varchar(150), activedate datetime, expiry datetime,
		CouponDesc varchar(250), totprints int, GS1Data varchar(100) null)
	insert into #Tmp1    
	select manufacturerid, couponid, ocr, company, activedate, expiry, ' ', 0, GS1Data
	  from cpnocr
	  where clearinghouse = 'cms' and ((ocr > '00000' and isnumeric(ocr) = 1) or gs1data > ' ') and company not like '%test%'
	  order by ocr, expiry 

   update #Tmp1 set ocr = 
        case when substring(gs1data,5,1) = 1 then substring(gs1data,13,6)
             when substring(gs1data,5,1) = 0 then substring(gs1data,12,6) 
             when substring(gs1data,5,1) = 2 then substring(gs1data,14,6) 
             else substring(gs1data,5,1) end
      where (gs1data is not null and isnumeric(substring(gs1data,5,1)) <> 0)
      and  (ocr = '' or ocr is null)

--drop table #Tmp1 

select *  from  #Tmp1 where GS1Data ='Not a coupon'

