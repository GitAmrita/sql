declare @pid int, @startdate datetime, @enddate datetime, @Email_Coup varchar(10), @Email_Promo varchar(10), @email_custom varchar(10)
select  @pid = 15005, @startdate='06/30/2010', @enddate = '07/13/2010', @email_custom = 10, @Email_Coup = null, @Email_Promo = null

declare @sql varchar (8000)

declare @Email_CoupL varchar(10), @Email_PromoL varchar(10)

select @Email_CoupL = convert(varchar(10),@Email_Coup),@Email_PromoL = convert(varchar(10),@Email_Promo)

--common to all cases
set @sql = 'SELECT	UserID as UserID,SyndicateID as SyndicateID,Email as Email,
				FirstName as FirstName,LastName as LastName,Addr1 as Addr1,Addr2 as Addr2,
				City as City,State as State,Zip as Zip,Email_Coup as Email_Coup,Email_Promo as Email_Promo,
				Pets as Pets,Add_Date as Add_Date,Chg_Date as Chg_Date,IsDeleted as IsDeleted,LastLogin as LastLogin,
				SessionCnt as SessionCnt,Email_Custom as Email_Custom
				FROM dbo.UserReg (nolock)
				WHERE syndicateid = ' + convert(varchar(5),@pid) + ' and add_date >= ''' + convert(varchar(20),@startdate) + ''' and add_date < ''' + convert(varchar(20),@enddate) + ''''

if @Email_CoupL is not null
begin
	if @Email_CoupL=0 
		set @sql = @sql + ' and (Email_Coup = ''' + @Email_CoupL + ''' or Email_Coup is null)'
	else
		set @sql = @sql + ' and Email_Coup = ''' + @email_CoupL + ''''
end

if @Email_Promo is not null
begin
	if @Email_Promo=0 
		set @sql = @sql + ' and (Email_Promo = ''' + @email_PromoL + ''' or Email_Promo is null)'
	else
		set @sql = @sql + ' and Email_Promo = ''' + @email_PromoL + ''''
end

if @email_custom is not null
begin
	if @email_custom=0 
		set @sql = @sql + ' and (email_custom = ''' + @email_custom + ''' or email_custom is null)'
	else
		set @sql = @sql + ' and email_custom = ''' + @email_custom + ''''
end

--print @sql

exec (@sql)