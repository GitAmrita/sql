--exec dbo.FCC_GetHeinzPinByOfferDetails2 '71107','07/02/2010','07/09/2010'


/*Create Table #Tmp_OfferCode ( OfferCode varchar(15), CouponID int)
CREATE clustered INDEX OC ON #Tmp_OfferCode (OfferCode, CouponID)

Create Table #Tmp_eb_email ( UserID int, CouponID int, PrintCount int, Email varchar(50), LastChanged datetime, OfferCode varchar(50))
CREATE clustered INDEX UCP1 ON #Tmp_eb_email (UserID, CouponID, PrintCount)
Create table #Tmp_UniqueRedeem (PIN varchar(100), UserID int, CouponID int, PrintCount int, RdmDate datetime, OfferCode varchar(15), PrtDate datetime)
create clustered index UR on #Tmp_UniqueRedeem (UserID, CouponID, PrintCount)
Create table #Tmp_UniqueRedeem2 (PIN varchar(100), CouponID int, RdmCount int, RdmDate datetime, OfferCode varchar(15), FirstPrint char(10))

create table #PinWork (PIN varchar(100), OfferCode varchar(15), couponid int, attempted int, prints int, firstprint char(10), redeemed int, deny_dev int,
       deny_pin int, deny_fraud int, deny_network int, deny_platform int, redemptiondate datetime null)
create clustered index PW on #PinWork(PIN)
--create index PW2 on #PinWork(OfferCode,couponid)
CREATE TABLE #TmpDP (PIN varchar(100), OfferCode varchar(15), CouponID int, Prints int, FirstPrinted varchar(10))
CREATE TABLE #Tmp_Offer_Distinct (OfferCode varchar(15))

Insert into #Tmp_OfferCode(OfferCode, CouponID) 
SELECT DISTINCT OfferCode, CouponID
    FROM Campaign_master (nolock)
    WHERE CompanyID = @CompanyID
    AND   OfferCode > ' '
    
INSERT INTO #Tmp_Offer_Distinct 
  SELECT DISTINCT OfferCode 
  FROM #Tmp_OfferCode
  
Insert into #Tmp_eb_email 
  Select e.UserID, e.CouponID, e.PrintCount, e.Email, e.LastChanged, e.OfferCode
  From eb_email e with (nolock) 
  inner join #Tmp_OfferCode oc with (nolock) on oc.OfferCode = e.OfferCode and oc.couponid = e.couponid*/
--SELECT * INTO #Destination FROM #Tmp_UniqueRedeem WHERE 1=2


/*Insert into #Tmp_UniqueRedeem
  SELECT DISTINCT em.Email, rc.UserID AS UserID, rc.CouponID AS CouponID, rc.PrintCount, rc.RdmDate AS RdmDate, rc.OfferCode, t.adddate
  FROM dbo.UniqueRedeem rc with (nolock)
  inner join #Tmp_eb_email em with (nolock) on rc.UserID = em.userID and rc.CouponID = em.CouponID and rc.PrintCount = em.PrintCount
  JOIN Distribution.dbo.TransactionMaster t on rc.userid = t.deviceid and rc.couponid = t.couponid and rc.printcount = t.transcount
  WHERE rc.RdmDate >= '07/02/2010' and rc.RdmDate < '07/09/2010'*/
/*insert into #PinWork
  select eb.email, eb.offerCD, 0, CASE WHEN eb.Clicks > 0 then 1 else 0 END, 0, ' ', 0,
    isnull(eb.dev_deny,0), isnull(eb.pin_deny,0), isnull(eb.fraud_deny,0), isnull(eb.coup_limit,0), isnull(eb.platform_deny,0), null
  from eb_validation eb with (nolock) 
  inner join #Tmp_Offer_Distinct oc with (nolock)on oc.OfferCode = eb.offercd
  where eb.LastChanged >= '07/02/2010' AND eb.LastChanged < '07/09/2010'*/
/*SELECT * INTO #Destination FROM #PinWork WHERE 1=2


SET ANSI_WARNINGS OFF
INSERT INTO #Destination
select eb.email, eb.offerCD, 0, CASE WHEN eb.Clicks > 0 then 1 else 0 END, 0, ' ', 0,
    isnull(eb.dev_deny,0), isnull(eb.pin_deny,0), isnull(eb.fraud_deny,0), isnull(eb.coup_limit,0), isnull(eb.platform_deny,0), null
  from eb_validation eb with (nolock) 
  inner join #Tmp_Offer_Distinct oc with (nolock)on oc.OfferCode = eb.offercd
  where eb.LastChanged >= '07/02/2010' AND eb.LastChanged < '07/09/2010'*/
/*SET ANSI_WARNINGS ON
select eb.email, eb.offerCD, 0, CASE WHEN eb.Clicks > 0 then 1 else 0 END, 0, ' ', 0,
    isnull(eb.dev_deny,0), isnull(eb.pin_deny,0), isnull(eb.fraud_deny,0), isnull(eb.coup_limit,0), isnull(eb.platform_deny,0), null
  from eb_validation eb with (nolock) 
  inner join #Tmp_Offer_Distinct oc with (nolock)on oc.OfferCode = eb.offercd
  where eb.LastChanged >= '07/02/2010' AND eb.LastChanged < '07/09/2010'
EXCEPT

SELECT * FROM #Destination */







