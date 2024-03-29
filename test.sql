USE [cupDB]
GO
/****** Object:  StoredProcedure [dbo].[rptStatusSummary_test1]    Script Date: 07/12/2012 13:15:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec rptStatusSummary_test1 '5/29/2012','6/4/2012','4,5'
-- DEALLOCATE dates
--DEALLOCATE users

ALTER PROCEDURE [dbo].[rptStatusSummary_test1]
    (
      @dtStart NVARCHAR(20) ,
      @dtEnd NVARCHAR(20),
	  @filter_id NVARCHAR(MAX)
    )
AS 
    BEGIN
		
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        
        CREATE TABLE #SummaryByReviewer
            (
              reviewer VARCHAR(50) ,
              reviewDate DATETIME ,
              reviewStatus VARCHAR(20) ,
              reviewTotal INT
            )
		CREATE TABLE #FilterID
			(
			Filter INT
			)

		INSERT INTO #FilterID
			SELECT t.* from dbo.StringListToTable(@filter_id,',')t 
        
        DECLARE @user INT
        DECLARE @username VARCHAR(50)
        DECLARE @date INT
		DECLARE @startDt_skey INT
		DECLARE @endDt_skey   INT

		SELECT @startDt_skey=date_skey FROM dbo.date_dim WHERE calendar_date = convert(varchar(10),@dtStart,101)
		SELECT @endDt_skey=date_skey   FROM dbo.date_dim WHERE calendar_date = convert(varchar(10),@dtend,101)
			

		/******************************************************************************************************************/
		/* Get the list of users that have reviewed images for given date range */
        DECLARE users CURSOR
        FOR

			SELECT DISTINCT a1.cup_user_id, a1.cup_user_name
			FROM    dbo.cup_user a1 
            JOIN dbo.log_image_status a2 ON a1.cup_user_id = a2.cup_user
			ORDER BY a1.cup_user_name
        
        OPEN users
        FETCH NEXT FROM users INTO @user, @username
        
        WHILE @@FETCH_STATUS = 0 
            BEGIN
		/******************************************************************************************************************/
		/* GET A LIST OF ALL THE DATES FOR GIVEN DATE RANGE */
                DECLARE dates CURSOR
                FOR
                    SELECT DISTINCT
                            date_skey
                    FROM    date_dim
                    WHERE   CAST(FLOOR(CAST(calendar_date AS FLOAT)) AS DATETIME) BETWEEN @dtStart AND @dtEnd
                OPEN dates
                FETCH NEXT FROM dates INTO @date

                WHILE @@FETCH_STATUS = 0 
                    BEGIN
					/* INSERT INTO TABLE HOW MANY PENDED AND PASSED */
                        INSERT  INTO #SummaryByReviewer
                                SELECT  cu.cup_user_name AS reviewer ,
                                        lis.create_date_skey AS reviewDate ,
                                        img.IMAGE_STATUS_DESC AS reviewStatus ,
                                        COUNT(lis.image_no) AS reviewTotal
                                FROM    log_image_status lis
                                        JOIN dbo.cup_user cu ON cu.cup_user_id = lis.cup_user
                                        JOIN dbo.IMAGE_STATUS_DEF img ON img.IMAGE_STATUS_NO = lis.image_status_no
										JOIN #FilterID f on lis.filter_id=f.filter
                                WHERE    lis.create_date_skey-@date = 0
                                        AND lis.cup_user = @user
                                GROUP BY cu.cup_user_name ,
                                        lis.create_date_skey ,
                                        img.IMAGE_STATUS_DESC
                                ORDER BY cu.cup_user_name ,
                                        lis.create_date_skey ,
                                        img.IMAGE_STATUS_DESC
                        
					/* INSERT INTO TABLE TOTAL FOR USER THAT DAY */
                        INSERT  INTO #SummaryByReviewer
                                SELECT  cu.cup_user_name AS reviewer ,
                                        lis.create_date_skey AS reviewDate ,
                                        NULL AS reviewStatus ,
                                        COUNT(lis.image_no) AS reviewTotal
                                FROM    log_image_status lis
                                        JOIN dbo.cup_user cu ON cu.cup_user_id = lis.cup_user
                                        JOIN dbo.IMAGE_STATUS_DEF img ON img.IMAGE_STATUS_NO = lis.image_status_no
										JOIN #FilterID f on lis.filter_id=f.filter
                                WHERE   lis.create_date_skey-@date= 0 AND lis.cup_user = @user
                                GROUP BY cu.cup_user_name ,
                                        lis.create_date_skey
                                ORDER BY cu.cup_user_name ,
                                        lis.create_date_skey                                      

                        FETCH NEXT FROM dates INTO @date
                    END

                CLOSE dates
                DEALLOCATE dates
			
			/* INSERT INTO TABLE TOTAL FOR USER FOR GIVEN DATE RANGE */

                INSERT  INTO #SummaryByReviewer
                        SELECT  cu.cup_user_name AS reviewer ,
                                NULL AS reviewDate ,
                                NULL AS reviewStatus ,
                                COUNT(lis.image_no) AS reviewTotal
                        FROM    log_image_status lis
                                JOIN dbo.cup_user cu ON cu.cup_user_id = lis.cup_user
                                JOIN dbo.IMAGE_STATUS_DEF img ON img.IMAGE_STATUS_NO = lis.image_status_no
								JOIN #FilterID f on lis.filter_id=f.filter
                        WHERE   lis.create_date_skey BETWEEN @startDt_skey AND @endDt_skey
                                AND lis.cup_user = @user
                        GROUP BY cu.cup_user_name
                        
                FETCH NEXT FROM users INTO @user, @username
            END
        
        CLOSE users
        DEALLOCATE users
        
        /* LASTLY INTO TABLE TOTAL FOR USER FOR GIVEN DATE RANGE */
                INSERT  INTO #SummaryByReviewer
                        SELECT  NULL AS reviewer ,
                                NULL AS reviewDate ,
                                NULL AS reviewStatus ,
                                COUNT(lis.image_no) AS reviewTotal
                        FROM    log_image_status lis
                                JOIN dbo.cup_user cu ON cu.cup_user_id = lis.cup_user
                                JOIN dbo.IMAGE_STATUS_DEF img ON img.IMAGE_STATUS_NO = lis.image_status_no
								JOIN #FilterID f on lis.filter_id=f.filter
                        WHERE  lis.create_date_skey-@date BETWEEN @startDt_skey AND @endDt_skey
                                
/******************************************************************************************************************/	

        
        SELECT  dd.calendar_date as reviewDate, isnull(reviewer,'') as reviewer, reviewTotal,isnull(reviewStatus,'')as reviewStatus
        FROM    #SummaryByReviewer s
		LEFT JOIN dbo.date_dim dd on dd.date_skey=isnull(s.reviewDate,'')
		ORDER BY reviewer,reviewdate

        DROP TABLE #SummaryByReviewer
		DROP TABLE  #FilterID
        
    END