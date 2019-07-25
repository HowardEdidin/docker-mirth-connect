USE mirthdb
GO

DECLARE @ADMIN_ID INT = 
(
    SELECT TOP 1 p.ID 
    FROM [dbo].[PERSON] AS p
    WHERE p.USERNAME = 'admin'
)

IF NOT EXISTS ((
        SELECT [PERSON_ID]
        FROM [dbo].[PERSON_PREFERENCE]
        WHERE NAME = 'firstlogin'
))
BEGIN
    INSERT INTO [dbo].[PERSON_PREFERENCE] 
    ([PERSON_ID], [NAME], [VALUE])
    VALUES
    (@ADMIN_ID , 'firstlogin', 'false'),
    (@ADMIN_ID , 'showNotificationPopup' , 'false'),
    (@ADMIN_ID , 'checkForNotifications' , 'true')
END