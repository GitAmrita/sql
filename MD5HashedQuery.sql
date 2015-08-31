declare  @CompanyID     int ,
		 @EndDt       DateTime   ,
		 @StartDt     DateTime
 
select  @CompanyID      = 1065,
		@EndDt        = '2012/01/17',
		@StartDt      = '2012/01/16'
		
CREATE TABLE #OfferWork (OfferCode varchar(15), CouponID int, CoupDesc varchar(200), CampDesc varchar(200))

CREATE TABLE #PinWork (PIN varchar(100), OfferCode varchar(15), PID varchar(15), couponid int, attempted int, 
						CoupType varchar(10), Summary varchar(200), MidLevel varchar(200), 
						CampDesc varchar(200), coupdesc varchar(200) null, printcount int, firstprint datetime,
						--redemption columns
						redeemed int,firstredeem datetime, deny_dev int, deny_pin int,
						deny_fraud int, deny_network int, deny_platform int,RetailerID varchar(10) null,
						--end of redemption columns
						shutoff datetime, expiry datetime, RollingDays int, PrintRunLimit int, 
						GroupLimit int,deviceid int)
						
CREATE TABLE #RdmWork (PIN varchar(100), OfferCode varchar(15), PID varchar(15), couponid int, attempted int, 
						CoupType varchar(10), Summary varchar(200), MidLevel varchar(200), 
						CampDesc varchar(200), coupdesc varchar(200) null, printcount int, firstprint datetime, redeemed int,
					    firstredeem datetime, deny_dev int, deny_pin int,
						deny_fraud int, deny_network int, deny_platform int, userid int, RetailerID varchar(10) null, 
						shutoff datetime, expiry datetime, RollingDays int, PrintRunLimit int, 
						GroupLimit int, lastprint datetime null, lastredeem datetime null, deviceid int)


--  Standard load for Bricks (Standard PIN reports)
INSERT INTO #OfferWork
    SELECT  DISTINCT  cm1.OfferCode, cm1.CouponID, cm1.CampDesc, cm0.CampDesc
    FROM Campaign_master cm1
    join Campaign_Master cm0 on cm1.campaignid = cm0.campaignid and cm0.camp_seq = 0
    WHERE cm1.CompanyID = 1065
    and   cm1.CouponID > 0 and (cm1.OfferCode ='' or cm1.OfferCode=null)
    
INSERT INTO #PinWork(PIN,OfferCode,PID,couponid,attempted,CoupType,Summary,MidLevel,CampDesc,CoupDesc,printcount,firstprint,  shutoff, expiry ,deviceid,redeemed,
					GroupLimit  ,RollingDays, PrintRunLimit )
       SELECT t.BID,'','',t.CouponID,1, 'Web', c.Summary,c.MidLevel, o.CampDesc, o.CoupDesc, t.TransCount,t.AddDate,c.shutoff,c.expiry, t.deviceid,0,isnull(gl.OriginalLimit,0),
        case when substring(c.disclaimer,1,1) = '{' and substring(c.disclaimer,4,1) = '}' then convert(int, substring(c.disclaimer,2,2))
             when substring(c.disclaimer,1,1) = '{' and substring(c.disclaimer,5,1) = '}' then convert(int, substring(c.disclaimer,2,3))
             when substring(c.disclaimer,1,1) = '{' and substring(c.disclaimer,3,1) = '}' then convert(int, substring(c.disclaimer,2,1))
             else 0
        end, -- fix later for rolling days
	    case when prl.Lim is null and c.printrunlimit is null then 0 
			 when prl.lim = 9999999 then 0
			 else prl.lim 
	    end as PrintRunLimit
    
  FROM Distribution.dbo.TransactionMaster t (nolock)
 join coupon_tbl c (nolock) on t.couponid = c.couponid
--  change to eliminate non-manufacturer prints from DFSI info  
  join #OfferWork o on t.couponid = o.couponid and o.offercode = ''
  left outer join printrunlimits prl (nolock) on t.couponid = prl.couponid
  left outer join Coupons.dbo.GPL_Census gc (nolock) on t.couponid = gc.couponid
  left outer join Coupons.dbo.GPL_Limits gl (nolock) on gc.groupid = gl.groupid
  WHERE t.TransType = 1 AND t.AddDate >= '2012/01/16' and t.AddDate < '2012/01/17'  
		and t.Channel not in ('15237','15292','15293','15294')
		
select * from #PinWork

 
  INSERT INTO #RdmWork(PIN , OfferCode , PID , couponid , attempted ,CoupType , Summary , MidLevel ,CampDesc , coupdesc , printcount , firstprint , redeemed ,  
					    firstredeem , deny_dev , deny_pin ,deny_fraud , deny_network , deny_platform , userid , RetailerID , shutoff , expiry , RollingDays ,
					     PrintRunLimit , GroupLimit , lastprint , lastredeem , deviceid )
					     
  SELECT dp.bid, '','',

  r.couponid, 1, 'web',
   
    c.summary, c.MidLevel, o.CampDesc, o.CoupDesc, --  fix brick later to differentiate brick and PnM
    dp.TransCount, dp.AddDate, 1, r.RdmDate, 0, 0, 0, 0, 0, dp.userid, null, c.Shutoff, c.Expiry, 
        case when substring(c.disclaimer,1,1) = '{' and substring(c.disclaimer,4,1) = '}' then convert(int, substring(c.disclaimer,2,2))
             when substring(c.disclaimer,1,1) = '{' and substring(c.disclaimer,5,1) = '}' then convert(int, substring(c.disclaimer,2,3))
             when substring(c.disclaimer,1,1) = '{' and substring(c.disclaimer,3,1) = '}' then convert(int, substring(c.disclaimer,2,1))
             else 0 end, -- fix later for rolling days
    case when prl.Lim is null and c.printrunlimit is null then 0 when prl.lim = 9999999 then 0 else prl.lim end as PrintRunLimit, isnull(gl.OriginalLimit,0), null, null, dp.deviceid
  FROM UniqueRedeem r
  JOIN Distribution.dbo.TransactionMaster dp with (nolock) on r.couponid = dp.couponid and r.userid = dp.deviceid and
        r.printcount = dp.TransCount and dp.TransType = 1
  left outer JOIN eb_email e with (nolock) ON e.userid = dp.deviceid AND e.couponid = dp.couponid
    AND e.printcount = dp.TransCount
  JOIN #OfferWork o on dp.couponid = o.couponid 
  join coupon_tbl c (nolock) on dp.couponid = c.couponid
 left outer join printrunlimits prl (nolock) on prl.couponid = dp.couponid
  left outer join Coupons.dbo.GPL_Census gc (nolock) on gc.couponid = dp.couponid
  left outer join Coupons.dbo.GPL_Limits gl (nolock) on gc.groupid = gl.groupid
  WHERE dp.TransType = 1 
  and dp.Channel not in ('15237','15292','15293','15294')
  AND   r.RdmDate >= '2012/01/16'
  AND   r.RdmDate <  '2012/01/17'
  
  
  
  insert into #PinWork(PIN , OfferCode , PID , couponid , attempted ,CoupType , Summary , MidLevel , CampDesc , coupdesc , printcount , firstprint, 
						redeemed ,firstredeem , deny_dev , deny_pin ,deny_fraud , deny_network , deny_platform ,RetailerID,shutoff , expiry, RollingDays , PrintRunLimit , 
						GroupLimit ,deviceid ) 
						
		select	PIN , OfferCode , PID , couponid , attempted , CoupType , Summary , MidLevel , CampDesc , coupdesc , printcount , firstprint,
				redeemed ,firstredeem , deny_dev , deny_pin ,deny_fraud , deny_network , deny_platform ,RetailerID,shutoff , expiry, RollingDays , PrintRunLimit , 
				GroupLimit ,deviceid  
		from #RdmWork
										
	UPDATE #PinWork SET deny_dev = e.dev_deny,deny_pin = e.pin_deny,deny_fraud = e.fraud_deny,deny_network = e.coup_limit,
    deny_platform = e.platform_deny, attempted = CASE WHEN e.Clicks > 0 then 1 else 0 END
  FROM #PinWork p
  JOIN eb_validation e with (nolock) on e.email = p.pin and e.offercd = p.OfferCode
  
SELECT top 500 SUBSTRING( (hashbytes('sha1',(CONVERT(varchar(10),firstprint,101)+CONVERT(varchar(10),deviceid)+CONVERT(varchar(2),printcount)))),3,100) as uniqueid,
PIN, OfferCode, CouponID, PrintCount, firstprint as PrintDate, Redeemed,
    case when firstredeem is null then '' else convert(varchar(10), firstredeem, 101) end as RedeemDate, 
    isnull(Deny_Dev,'') as Deny_Dev, isnull(Deny_Pin,'') as Deny_PIN,isnull(Deny_Fraud,'') as  Deny_Fraud,isnull(Deny_Network,'')as Deny_Network, 
    isnull(Deny_Platform,'') as Deny_Platform, isnull(RetailerID,'') as RetailerID,
     PID, CoupType, Summary, MidLevel, CampDesc, CoupDesc, shutoff, expiry, RollingDays, PrintRunLimit, GroupLimit
    
  FROM #PinWork
  ORDER BY couponid, OfferCode, PIN, PrintCount
  
drop table #OfferWork
drop table  #PinWork
drop table #RdmWork
