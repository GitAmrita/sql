

SELECT  lis.image_no ,
        lis.image_status_no ,
        lis.image_status_reason_no
FROM    dbo.log_image_status lis
        JOIN ( SELECT   MAX(log_skey) AS log_skey
               FROM     dbo.log_image_status
               WHERE    create_date_skey = 105634
                        AND cup_user = 10
               GROUP BY image_no
             ) t ON lis.log_skey = t.log_skey