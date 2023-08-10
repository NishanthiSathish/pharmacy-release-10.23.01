/*************************************************************************************************************************************************
 * Modification History
 * ====================
 *
 * 1 20Apr09 XN  F0030035  Created
 * 2 03May11 XN  F0116218	 Updates to make easier to install
 *				 F0116221
 * 3 06May11 XN  F0116868  Stores Orders->Robot Loading second screen is not enabled for second robot.
 *               F0116869  Stock return is a bit slow 
 * 4 24May11 XN  F0117054  Prevent IPReceiver logging 'No destination table defined' message
 * 5 16Jun11 XN			   added message to send all errors to robot
 * 6 05Jul11 XN            Removed main patch items
 * 7 14Sep11 XN            Upgardes to pUserInsert
 * 8 15Seo11 XN			   tfs 14120 Integration Issues
 * 9 19Sep12 XN			   add extra field to pUserInsert statments
 *10 28Jun13 XN			   [PharmacyCounter] don't append the robotlocation to pharmacy counter key so matches code
 *11 02Oct13 XN     74592  Upgrade of Pharamcy to .NET4 means robot loader does not work with the EIE which is still .NET2
 *						   Fixed by moving the robot loader reply component to the web site
 *12 09Sep21 AS  MM-8050:  Robot Loader Interface configuration script.sql needs updating for 10.22
 *************************************************************************************************************************************************/

DECLARE @ComponentLauncherID			INT
DECLARE @ComponentLauncherEntityID		INT
DECLARE @ComponentPath				VARCHAR(256)
DECLARE @IPReceiverID				INT
DECLARE @IpReceiverEntityID			INT
DECLARE @InstallationPath 			VARCHAR(256)
DECLARE @InstanceName				VARCHAR(50)
DECLARE @InterfaceInstanceID			INT
DECLARE @InterfaceTableID			INT
DECLARE @Key					VARCHAR(50)
DECLARE @Now					DATETIME
DECLARE @100Year					DATETIME
DECLARE @Pwd					VARCHAR(50)
DECLARE @ServiceName				VARCHAR(128)
DECLARE @SessionID				INT
DECLARE @System					VARCHAR(50)
DECLARE @UserTableID				INT
DECLARE @RobotName				VARCHAR(25)
DECLARE @RobotSiteNumber			VARCHAR(25)
DECLARE @RobotLocation				VARCHAR(25)
DECLARE @RobotSiteID				INT
DECLARE @LocalRobotPort             VARCHAR(25)
DECLARE @InterfaceEngineUsername    VARCHAR(50)    
DECLARE @InterfaceEnginePassword    VARCHAR(200)    
DECLARE @IpReceiverUsername         VARCHAR(50)    
DECLARE @EveryoneRoleID				INT  


--************************************************************************************************************************
--************************************************************************************************************************
-- *** Set variables below prior to running this script. ***


SET @InstallationPath 	= 'C:\InterfaceEngine\Live' -- e.g. 'C:\InterfaceEngine RobotLoader\Live'
SET @RobotSiteNumber	= '3'						-- e.g. 503
SET @RobotLocation	    = 'RBT'						-- e.g. RB1

--************************************************************************************************************************

SET @ServiceName             = 'RobotLoader'
SET @InstanceName 	         = 'RobotLoader'  
SET @LocalRobotPort          = '5511'

SET @InterfaceEngineUsername = 'RobotLoaderInterfaceEngine'
SET @IpReceiverUsername      = 'RobotLoaderIpReceiver'

--************************************************************************************************************************

SET @RobotName = 'Rowa'
--
--************************************************************************************************************************
--************************************************************************************************************************

-- 02Oct13 XN 74592 Remove old settings (can be removed after a couple of years)
DELETE FROM Setting where [System]='RobotLoaderReplyComponent' and Section=@InstanceName	
DELETE FROM Setting where [System]='IPReceiver'				   and Section=@InstanceName AND [Key] in ('ReplyComponentName', 'ReplyComponentDllName')

/************************************************************************************************************************
 *	
 * Create the user accounts 
 *
 ************************************************************************************************************************/

SELECT @UserTableID = [TableID] 
FROM [Table]
WHERE [Description] = 'User'

SET @Now = getdate()
SET @100Year = DATEADD(year, 100, @Now)

exec @EveryoneRoleID = pRoleIDEveryoneBySession @SessionID   

SELECT @ComponentLauncherEntityID = EntityID  FROM [User] WHERE [Username] = @InterfaceEngineUsername

IF @ComponentLauncherEntityID IS NULL
	BEGIN
		IF EXISTS(select TOP 1 1 from VersionLog where [type] Like 'Encryption' and Description Like 'AES')
			set @Pwd = 'YirUnLoslsKg5xtDAzpa8iGAf2LNnLNi|7000|jynoIafSTHJd15fKNrn/UGdVRYTeFPSK'
		ELSE
			set @Pwd = icwsys.encode('Core1234', 2.1, 1.4)

		exec pUserInsert   @SessionID,
                         0,
                         @UserTableID,
                         'Interface Engine',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         'IFENG',
						 'Interface',
                         'Engine',
                         NULL,
                         NULL,
                         0,
                         @InterfaceEngineUsername,
                         @Pwd,
                         @Now,
                         @Now,
                         0,
                         0,
						 0,                    						 		 
                         999,
                         @Now,
                         @100Year,
						 1,
						 0,
						 0,
						 0,
						 @ComponentLauncherEntityID OUTPUT
						 		 
        IF NOT EXISTS(SELECT TOP 1 1 FROM UserLinkRole WHERE EntityID=@ComponentLauncherEntityID AND RoleID=@EveryoneRoleID)
    		exec pUserLinkRoleInsert @SessionID, @ComponentLauncherEntityID, @EveryoneRoleID

		PRINT 'InterfaceEngine user account created with EntityID = ' + CAST(@ComponentLauncherEntityID AS Varchar(13))
		PRINT ''
	END
ELSE
	BEGIN 
		EXEC pUserUpdate @SessionID, @ComponentLauncherEntityID, 0, @UserTableID,'Interface Engine', NULL, NULL, NULL, NULL, NULL,'IFENG', 'Interface', 'Engine', NULL, NULL, 0,@InterfaceEngineUsername,'YirUnLoslsKg5xtDAzpa8iGAf2LNnLNi|7000|jynoIafSTHJd15fKNrn/UGdVRYTeFPSK', @Now, @Now, 0, 0, 0, 999, @Now, @100Year, 1, 0, 0
	END

SELECT @IpReceiverEntityID = EntityID  FROM [User] WHERE [Username] = @IpReceiverUsername

IF @IpReceiverEntityID IS NULL
	BEGIN
		IF EXISTS(select TOP 1 1 from VersionLog where [type] Like 'Encryption' and Description Like 'AES')
			set @Pwd = 'hJfzX8+T5bl5mxRjX1c4Di4NTtoIiSjX|7000|DdHNay++febJVWHDbZO7ZqsgFLfW7zI9'
		ELSE
			set @Pwd = icwsys.encode('Core1234', 2.1, 1.4)

		exec pUserInsert   @SessionID,
                         0,
                         @UserTableID,
                         'Robot Loader Ip Receiver',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         'RLIP',
						 'Ip',
                         'Receiver',
                         NULL,
                         NULL,
                         0,
                         @IpReceiverUsername,
                         @Pwd,
                         @Now,
                         @Now,
                         0,
                         0,
						 0,
                         999,
                         @Now,
                         @100Year,
						 1,
						 0,
						 0,
						 0,
						 @IpReceiverEntityID OUTPUT

        IF NOT EXISTS(SELECT TOP 1 1 FROM UserLinkRole WHERE EntityID=@IpReceiverEntityID AND RoleID=@EveryoneRoleID)
		    exec pUserLinkRoleInsert @SessionID, @IpReceiverEntityID, @EveryoneRoleID

		PRINT 'RLIpReceiver user account created with EntityID = ' + CAST(@IpReceiverEntityID AS Varchar(13))
		PRINT ''
	END
ELSE
	BEGIN
		BEGIN 
			EXEC pUserUpdate @SessionID, @IpReceiverEntityID, 0, @UserTableID,'Robot Loader Ip Receiver', NULL, NULL, NULL, NULL, NULL,'RLIP', 'Ip', 'Receiver', NULL, NULL, 0,@IpReceiverUsername,'hJfzX8+T5bl5mxRjX1c4Di4NTtoIiSjX|7000|DdHNay++febJVWHDbZO7ZqsgFLfW7zI9', @Now, @Now, 0, 0, 0, 999, @Now, @100Year, 1, 0, 0
		END 
	END

IF LEN(@InstallationPath) > 0 
	BEGIN
		/************************************************************************************************************************
		 *	
		 * Create the Components
		 *
		 ************************************************************************************************************************/
		SET @SessionID = 1

		-- Ensure the string does not end with '\'
		IF RIGHT(RTRIM(@InstallationPath),1) <> '\'
		    SET @InstallationPath = @InstallationPath + '\'
		    
		-- Get Robot Site		 
		SELECT @InterfaceInstanceID = [InterfaceInstanceID]
		FROM [InterfaceInstance]
		WHERE [Description] = @InstanceName

		IF (@InterfaceInstanceID IS NULL)
		BEGIN
			EXEC [pInterfaceInstanceInsert] @SessionID, @InstanceName, 'Robot Loader Interface', @ServiceName, @InterfaceInstanceID OUTPUT
		END

		PRINT 'Robot Loader Interface InstanceID = ' + CAST(@InterfaceInstanceID AS VARCHAR(13))
		PRINT ''

		SELECT @ComponentLauncherID = [InterfaceComponentID]
		FROM [InterfaceComponent]
		WHERE [Name] = 'ComponentLauncher'
		AND [InterfaceInstanceID] = @InterfaceInstanceID

		IF (@ComponentLauncherID IS NULL)
		BEGIN

			EXEC [pInterfaceComponentInsert]		@SessionID
												,	@InterfaceInstanceID
												,	'ComponentLauncher'
												,	''
												,	''
												,	@InstanceName
												,	@ComponentLauncherEntityID
												,	0
												,	0
												,	0
												,	@ComponentLauncherID OUTPUT
		END

		PRINT 'Component Launcher is InterfaceComponentID ' + CAST(@ComponentLauncherID AS VARCHAR(13))
		PRINT ''

		SELECT @IPReceiverID = [InterfaceComponentID]
		FROM [InterfaceComponent]
		WHERE [Name] = 'IpReceiver'
		AND [InterfaceInstanceID] = @InterfaceInstanceID

		IF (@IPReceiverID IS NULL)
		BEGIN

			SET @ComponentPath = @InstallationPath + 'IpReceiver.dll'

			EXEC [pInterfaceComponentInsert]		@SessionID
												,	@InterfaceInstanceID
												,	'IpReceiver'
												,	@ComponentPath
												,	'ascribeplc.interfaces.common.ipreceiver.IpReceiver'
												,	@InstanceName
												,	@IpReceiverEntityID
												,	0
												,	0
												,	1
												,	@IPReceiverID OUTPUT
		END

		PRINT 'IPReceiver Component is InterfaceComponentID ' + CAST(@IPReceiverID AS VARCHAR(13))
		PRINT ''
        
		--************************************************************************************************************************
		--************************************************************************************************************************
		--
		--  Create the settings for the PharmacyReplyComponent Component.
		--
		--************************************************************************************************************************
		--************************************************************************************************************************
		SET @System = 'PharmacyReplyComponent'

		PRINT 'Creating the ' + @System + ' Component configuration settings.'

		PRINT ''
		SET @Key = 'RobotName'

		IF LEN(@RobotName) > 0
		BEGIN
			IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
			BEGIN
				EXEC [pSettingInsert]		@SessionID
										,	@System
										,	@InstanceName
										,	@Key
										,	@RobotName
										,	0
										,	'Name of the supported robot interface (currently only supports Rowa)'
				PRINT 'Created ' + @Key + ' configuration setting.'
			END
			ELSE
				PRINT @Key + ' already exists'
		END
		ELSE
			PRINT 'SCRIPT FAILED - You have not set the robot name variable at the beginning of the script.'

		PRINT ''
		SET @Key = 'SiteNumber'

		IF LEN(@RobotSiteNumber) > 0
		BEGIN
			IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
			BEGIN
				EXEC [pSettingInsert]		@SessionID
										,	@System
										,	@InstanceName
										,	@Key
										,	@RobotSiteNumber
										,	0
										,	'Site the robot handles loadings for'
				PRINT 'Created ' + @Key + ' configuration setting.'
			END
			ELSE
				PRINT @Key + ' already exists'
		END
		ELSE
			PRINT 'SCRIPT FAILED - You have not set the robot site number variable at the beginning of the script.'

		PRINT ''
		SET @Key = 'Location'

		IF LEN(@RobotLocation) > 0
		BEGIN
			IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
			BEGIN
				EXEC [pSettingInsert]		@SessionID
										,	@System
										,	@InstanceName
										,	@Key
										,	@RobotLocation
										,	0
										,	'Location the robot handles loadings for'
				PRINT 'Created ' + @Key + ' configuration setting.'
			END
			ELSE
				PRINT @Key + ' already exists'
		END
		ELSE
			PRINT 'SCRIPT FAILED - You have not set the robot location variable at the beginning of the script.'

		PRINT ''
		SET @Key = 'ReplyComponentType'

		IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
		BEGIN
			EXEC [pSettingInsert]		@SessionID
									,	@System
									,	@InstanceName
									,	@Key
									,	'RobotLoading'
									,	0
									,	'Component to load on other side of the Pharmacy EIE web interface'
			PRINT 'Created ' + @Key + ' configuration setting.'
		END
		ELSE
			PRINT @Key + ' already exists'

		--************************************************************************************************************************
		--************************************************************************************************************************
		--
		--  Create the settings for the IPReceiver Component.
		--
		--************************************************************************************************************************
		--************************************************************************************************************************
		SET @System = 'IPReceiver'

		PRINT ''
		PRINT 'Creating the ' + @System + ' Component configuration settings.'

		PRINT ''
		SET @Key = 'LogSentReceivedMsgs'

		IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
		BEGIN
			EXEC [pSettingInsert]		@SessionID
									,	@System
									,	@InstanceName
									,	@Key
									,	'FALSE'
									,	0
									,	'"TRUE" = Logging On : "FALSE" = Logging Off'
			PRINT 'Created ' + @Key + ' configuration setting.'
		END
		ELSE
			PRINT @Key + ' already exists'

		PRINT ''
		SET @Key = 'LocalIpPort'

		IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
		BEGIN
			EXEC [pSettingInsert]		@SessionID
									,	@System
									,	@InstanceName
									,	@Key
									,	@LocalRobotPort
									,	0
									,	'The TCPIP Port that the IPReceiver will listen on to receive messages.'
			PRINT 'Created ' + @Key + ' configuration setting.'
		END
		ELSE
			PRINT @Key + ' already exists'

		PRINT ''
		SET @Key = 'MsgRequiresAResponse'

		IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
		BEGIN
			EXEC [pSettingInsert]		@SessionID
									,	@System
									,	@InstanceName
									,	@Key
									,	'TRUE'
									,	0
									,	'"TRUE" = Send a reply : "FALSE" = Don''t send a reply.'
			PRINT 'Created ' + @Key + ' configuration setting.'
		END
		ELSE
			PRINT @Key + ' already exists'

		PRINT ''
		SET @Key = 'ReplyComponentName'

		IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
		BEGIN
			EXEC [pSettingInsert]		@SessionID
									,	@System
									,	@InstanceName
									,	@Key
									,	'ascribeplc.interfaces.replycomponents.pharmacyintegrationreplycomponent.PharmacyIntegrationReplyComponent'
									,	0
									,	'Full .Net namespace of the Reply Component class name.'
			PRINT 'Created ' + @Key + ' configuration setting.'
		END
		ELSE
			PRINT @Key + ' already exists'

		PRINT ''
		SET @Key = 'ReplyComponentDllName'

		IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
		BEGIN

			SET @ComponentPath = @InstallationPath + 'Pharmacy Integration Reply Component.dll'

			EXEC [pSettingInsert]		@SessionID
									,	@System
									,	@InstanceName
									,	@Key
									,	@ComponentPath
									,	0
									,	'The filename including the path of the Reply Component DLL file.'
			PRINT 'Created ' + @Key + ' configuration setting.'
		END
		ELSE
			PRINT @Key + ' already exists'

		PRINT ''
		SET @Key = 'UseMLLPEncoding'

		IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
		BEGIN
			EXEC [pSettingInsert]		@SessionID
									,	@System
									,	@InstanceName
									,	@Key
									,	'TRUE'
									,	0
									,	'"TRUE" = Use MLLP Encoding : "FALSE" = Don''t use MLLP Encoding.'
			PRINT 'Created ' + @Key + ' configuration setting.'
		END
		ELSE
			PRINT @Key + ' already exists'

		PRINT ''
		SET @Key = 'RequiresDestinationTable'

		IF NOT EXISTS(SELECT * FROM [Setting] WHERE [System] = @System AND [Section] = @InstanceName AND [Key] = @Key)
		BEGIN
			EXEC [pSettingInsert]		@SessionID
									,	@System
									,	@InstanceName
									,	@Key
									,	'FALSE'
									,	0
									,	'"TRUE" = component requires a destination table, "FALSE" = component does not require a destination table.'
			PRINT 'Created ' + @Key + ' configuration setting.'
		END
		ELSE
			PRINT @Key + ' already exists'

		PRINT ''
		PRINT 'Finished creating ' + @System + ' settings.'
		
		
		--************************************************************************************************************************
		--************************************************************************************************************************
		--
		--  Add the message templates to the RobotLoadingMsgTemplate table
		--
		--************************************************************************************************************************
		--************************************************************************************************************************
		DELETE FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa'
		
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [MessageType] Like 'ReceivedHeader')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'ReceivedHeader', 'ArxRowaReceivedHeader', 'MSH|^~\&|||||[HL7DataTime]||ZIN|[MessageControlID]|P|2.3|||AL|AL|||')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'AskNewDeliver')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Received', 'AskNewDeliver', 'ZIN|B|B|[Empty]||[LoadingNumber:>0]')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'AskDrugInputRight')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Received', 'AskDrugInputRight', 'ZIN||[DrugBarcode:=13]|[Empty]||[LoadingNumber:<15]')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'AskDrugReturnRight')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Received', 'AskDrugReturnRight', 'ZIN||[DrugBarcode:=13]|[Empty]||               |')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'WarnEndOfDelivery')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Received', 'WarnEndOfDelivery', 'ZIN|E|E|[Empty]||[LoadingNumber]')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'CaseOfStockReturn')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Received', 'CaseOfStockReturn', 'ZIN||[DrugBarcode:=13]|[Dummy:>=1]||               ')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'CaseOfNewDelivery')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Received', 'CaseOfNewDelivery', 'ZIN||[DrugBarcode:=13]|[Dummy:>=1]||[LoadingNumber:<15]')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'AskDrugInfo')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Received', 'AskDrugInfo', 'ZIN|[DrugBarcode:=13]|I|||[LoadingNumber]')

        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [MessageType] Like 'ReplyHeader')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'ReplyHeader', 'ArxRowaReplyHeader', 'MSH|^~\&|ClientPC|ASC|InterfacePC||[HL7DataTime]||ACK|[MessageControlID]|P|2.3|||AL|AL|44||')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'ReplyNewDeliveryValid')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Reply', 'ReplyNewDeliveryValid', 'MSA|AD|[MessageControlID]||||')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'ReplyNewDeliveryInvalid')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Reply', 'ReplyNewDeliveryInvalid', 'MSA|AF|[MessageControlID]|[Error]|||')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'ReplyDrugInfoNotFound')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Reply', 'ReplyDrugInfoNotFound', 'MSA|AN|[MessageControlID]||||')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'ReplyDrugAllowed')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Reply', 'ReplyDrugAllowed', 'MSA|IA|[MessageControlID]||||')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'ReplyDrugNotAllowed')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Reply', 'ReplyDrugNotAllowed', 'MSA|IB|[MessageControlID]|[ErrorCode]^[Error]|||')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'ReplyItemTakenByIT')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Reply', 'ReplyItemTakenByIT', 'MSA|AT|[MessageControlID]||||')
        If NOT EXISTS(SELECT TOP 1 * FROM RobotLoadingMsgTemplate WHERE [RobotName] Like 'Rowa' AND [Name] Like 'ReplyError')
	        INSERT INTO RobotLoadingMsgTemplate ([RobotName], [MessageType], [Name], [MessageTemplate]) VALUES ('Rowa', 'Reply', 'ReplyError', 'MSA|AE|[MessageControlID]|[Error]|||')
	    
	        
		--************************************************************************************************************************
		--************************************************************************************************************************
		--	        
        -- Add the robot location to MechDisp
        -- Only fill in values for LocationCode, and FindItemScreenChar, so can update the displays
		--	        
		--************************************************************************************************************************
		--************************************************************************************************************************		
		SELECT @RobotSiteID=LocationID FROM Site WHERE SiteNumber=@RobotSiteNumber			    
		
        IF NOT(@RobotSiteID is NULL)  AND
           NOT EXISTS(SELECT TOP 1 1 FROM WConfiguration WHERE (SiteID=@RobotSiteID) AND (Category Like 'D|MechDisp') AND ([Key] Like 'LocationCode') AND (VALUE='"' + @RobotLocation + '"'))
        BEGIN
            DECLARE @robotCount varchar(10)    
            DECLARE @section varchar(10)
            
            IF NOT EXISTS(SELECT TOP 1 1 FROM WConfiguration WHERE (SiteID=@RobotSiteID) AND (Category Like 'D|MechDisp') AND (Section='') AND ([Key] Like 'Total'))
            BEGIN
                SET @robotCount = 1
                INSERT INTO WConfiguration (SiteID, Category, Section, [Key], Value) VALUES (@RobotSiteID, 'D|MechDisp', '',  'Total', '"1"')
            END
            ELSE
            BEGIN
                select @robotCount = SUBSTRING(Value, 2, LEN(Value) - 2) from WConfiguration WHERE (SiteID=@RobotSiteID) AND (Category Like 'D|MechDisp') AND Section='' AND ([Key] Like 'Total')
                set @robotCount = CAST(@robotCount as int) + 1
                UPDATE WConfiguration SET Value='"' + CAST(@robotCount as varchar(5)) + '"' WHERE (SiteID=@RobotSiteID) AND (Category Like 'D|MechDisp') AND Section='' AND ([Key] Like 'Total')
            END
            
            IF NOT EXISTS(SELECT TOP 1 1 FROM WConfiguration WHERE (SiteID=@RobotSiteID) AND (Category Like 'D|MechDisp') AND Section=@robotCount AND ([Key] Like 'LocationCode'))
                INSERT INTO WConfiguration (SiteID, Category, Section, [Key], Value) VALUES (@RobotSiteID, 'D|MechDisp', @robotCount, 'LocationCode', '"' + @RobotLocation + '"')
            IF NOT EXISTS(SELECT TOP 1 1 FROM WConfiguration WHERE (SiteID=@RobotSiteID) AND (Category Like 'D|MechDisp') AND Section=@robotCount AND ([Key] Like 'FindItemScreenChar'))
                INSERT INTO WConfiguration (SiteID, Category, Section, [Key], Value) VALUES (@RobotSiteID, 'D|MechDisp', @robotCount, 'FindItemScreenChar', '"R"')    
        END	        


		--************************************************************************************************************************
		--************************************************************************************************************************
		--
		--  Add a counter in the PharmacyCounter table
		--
		--************************************************************************************************************************
		--************************************************************************************************************************
		IF NOT(@RobotSiteID is NULL) 
		BEGIN
			DECLARE @PharmacyCounterSystem  as varchar(50)
			DECLARE @PharmacyCounterSection as varchar(50)
			DECLARE @PharmacyCounterKey 	as varchar(50)
			DECLARE @PharmacyCounterID      as int

			SET @PharmacyCounterSystem = 'RobotLoading'
			SET @PharmacyCounterSection= 'LoadingNumber'
			SET @PharmacyCounterKey    = 'Location'	-- + @RobotLocation XN 28Jun13 removed robot location so matches how code works
			
			IF NOT EXISTS(SELECT * FROM [PharmacyCounter] WHERE siteID=@RobotSiteID AND [System]=@PharmacyCounterSystem AND [Section]=@PharmacyCounterSection AND [Key]=@PharmacyCounterKey)
			BEGIN
				Exec pPharmacyCounterInsert 0, @RobotSiteID, @PharmacyCounterSystem, @PharmacyCounterSection, @PharmacyCounterKey, 1, '{DateTime:yyMMdd}{Count:000}', @Now, 'Daily', null, 0, @PharmacyCounterID
				PRINT 'Created counter in PharmacyCounter table.'
			END
			ELSE
				PRINT 'PharmacyCounter for robot already exists'
		END
		ELSE
			PRINT 'SCRIPT FAILED - Invalid site number ' + @RobotSiteNumber
			
		--************************************************************************************************************************
		--************************************************************************************************************************
		--		
        -- Return the password
		--		
		--************************************************************************************************************************
		--************************************************************************************************************************
        If Exists(select top 1 1 from VersionLog where (Description Like 'AES') and (Type Like 'Encryption'))
            set @InterfaceEnginePassword = (SELECT top 1 [PASSWORD] FROM [user] WHERE Username=@InterfaceEngineUsername)
        ELSE
            set @InterfaceEnginePassword = (SELECT top 1 icwsys.Decode('01612808080', [PASSWORD]) FROM [user] WHERE Username=@InterfaceEngineUsername)
        
        PRINT ''
        PRINT 'Interface Engine Password: ' + @InterfaceEnginePassword
	END
ELSE
	PRINT 'SCRIPT FAILED - You have not set variables at the beginning of the script.'
GO	
	
--************************************************************************************************************************
--************************************************************************************************************************
--		
-- Setup Monitor Jobs
--		
--************************************************************************************************************************
--************************************************************************************************************************
 
-- Tidy order loading table
Exec pDrop 'pOrderLoadingTidy'
GO

CREATE PROCEDURE [pOrderLoadingTidy]
(
        @CurrentSessionID		INT
    ,	@InterfaceComponentID	INT
    ,	@StepID					INT
)
AS
BEGIN
    DECLARE @now DATETIME
    DECLARE @numofdays INT

    SET @now = getdate()

    IF OBJECT_ID('tempdb..#messagetidy') IS NOT NULL
        DROP table #messagetidy
    	
	-- Get the robot loading with the largest limit to display loadings from date
	-- and use this value ass the cut off time in days    	
    SELECT @numofdays = MAX(CAST([Setting].[Value] AS INT))
    FROM [Setting]
    WHERE [System]  = 'Pharmacy'      AND 
          [Key]     = 'LimitToDisplayLoadingsFromDate'
    GROUP BY [Key] 

	-- Get all the order loadings to delete from the cut off date
    SELECT OrderLoadingID INTO #messagetidy
        FROM OrderLoading WHERE CreatedDateTime < DATEADD(dd, -@numofdays, @now)
        
	-- And delete        
    DELETE FROM OrderLoadingException 
    WHERE [OrderLoadingException].[OrderLoadingID] IN (SELECT [OrderLoadingID] FROM #messagetidy)   

    DELETE FROM OrderLoadingDetail    
    WHERE [OrderLoadingDetail].[OrderLoadingID] IN (SELECT [OrderLoadingID] FROM #messagetidy) 
    
    DELETE FROM WReconcilLinkOrderLoading  
    WHERE [WReconcilLinkOrderLoading].[OrderLoadingID] IN (SELECT [OrderLoadingID] FROM #messagetidy) 

    DELETE FROM OrderLoading  
    WHERE [OrderLoading].[OrderLoadingID] IN (SELECT [OrderLoadingID] FROM #messagetidy)   

    DROP table #messagetidy
END
GO

EXEC pRoutineSave 'pOrderLoadingTidy', 'Stored Procedure', 'OrderLoadingTidy'
GO

-- set OrderLoadingTidy script as monitor job.
DECLARE @InterfaceInstanceID int
DECLARE @MonitorScheduleID   int
DECLARE @JobDescription varchar(50)
DECLARE @JobDetail varchar(250)
DECLARE @RoutineID int
DECLARE @now datetime
DECLARE @MonitorJobID int

SET @now            = GETDATE()
SET @JobDescription = 'OrderLoadingTidy'
SET @JobDetail      = 'Tidy up the order loading tables.'

SELECT TOP 1 @MonitorScheduleID=MonitorScheduleID FROM MonitorSchedule WHERE Occurs IS NOT NULL
SELECT TOP 1 @RoutineID=RoutineID                 FROM Routine         WHERE [Description] Like 'OrderLoadingTidy'

IF (SELECT CURSOR_STATUS('global','monitorInterfaceComponents')) >= -1
BEGIN 
    DEALLOCATE monitorInterfaceComponents
END

IF EXISTS(SELECT TOP 1 1 FROM InterfaceComponent WHERE (Name Like 'Monitor') AND Start=1)
	SELECT TOP 1 @InterfaceInstanceID=InterfaceInstanceID FROM InterfaceComponent WHERE (Name Like 'Monitor') AND Start=1 ORDER BY InterfaceInstanceID
ELSE
	SELECT TOP 1 @InterfaceInstanceID=InterfaceInstanceID FROM InterfaceInstance WHERE (Description Like 'RobotLoader%')

IF NOT EXISTS (SELECT TOP 1 1 FROM MonitorJob WHERE (InterfaceInstanceID=@InterfaceInstanceID) AND (Description Like @JobDescription))
    INSERT INTO MonitorJob (InterfaceInstanceID, Description, Detail, MonitorScheduleID, NextRun, LastRun, LastRun_StatusID, Active)
        VALUES (@InterfaceInstanceID, @JobDescription, @JobDetail, @MonitorScheduleID, DATEADD(hh, 1, @now), @now, 0, 1)
        
SELECT @MonitorJobID=MonitorJobID FROM MonitorJob WHERE (InterfaceInstanceID=@InterfaceInstanceID) AND (Description Like @JobDescription)

IF (@MonitorJobID IS NOT NULL) AND 
   (@RoutineID    IS NOT NULL) AND 
    NOT EXISTS(SELECT TOP 1 1 FROM MonitorStep WHERE (MonitorJobID=@MonitorJobID) AND (Description Like @JobDescription))
    INSERT INTO MonitorStep (MonitorJobID, StepOrder, Description, Detail, RoutineID, FailureTransformPath, SuccessTransformPath, Active)
        VALUES (@MonitorJobID, 1, @JobDescription, @JobDetail, @RoutineID, null, null, 1)
GO

-- Remove 'No destination table defined for InterfaceComponentID' from applicationlog
Exec pDrop 'pIpRecieverTidy'
GO

CREATE PROCEDURE [pIpRecieverTidy]
(
        @CurrentSessionID		INT
    ,	@InterfaceComponentID	INT
    ,	@StepID					INT
)
AS
BEGIN
    DECLARE @now DATETIME
    DECLARE @numofdays INT

    SET @now = getdate()

    IF OBJECT_ID('tempdb..#messagetidy') IS NOT NULL
	    DROP table #messagetidy

    SELECT top 1000 ApplicationLogID INTO #messagetidy
	    FROM ApplicationLog WHERE Description Like 'No destination table defined for InterfaceComponentID%'

    DELETE FROM ApplicationError WHERE ApplicationLogID in (SELECT ApplicationLogID FROM #messagetidy)
    DELETE FROM ApplicationLog   WHERE ApplicationLogID in (SELECT ApplicationLogID FROM #messagetidy)

    DROP table #messagetidy
END
GO

EXEC pRoutineSave 'pIpRecieverTidy', 'Stored Procedure', 'IpRecieverTidy'
GO

-- set tidy script as monitor job.
DECLARE @InterfaceInstanceID int
DECLARE @MonitorScheduleID   int
DECLARE @JobDescription varchar(50)
DECLARE @JobDetail varchar(250)
DECLARE @RoutineID int
DECLARE @now datetime
DECLARE @MonitorJobID int

SET @now            = GETDATE()
SET @JobDescription = 'IpRecieverTidy'
SET @JobDetail      = 'Tidy up "No destination table defined for InterfaceComponentID" error.'

SELECT TOP 1 @MonitorScheduleID=MonitorScheduleID FROM MonitorSchedule WHERE Name = 'Hourly'
SELECT TOP 1 @RoutineID=RoutineID                 FROM Routine         WHERE [Description] Like 'IpRecieverTidy'

IF (SELECT CURSOR_STATUS('global','monitorInterfaceComponents')) >= -1
BEGIN 
    DEALLOCATE monitorInterfaceComponents
END

IF EXISTS(SELECT TOP 1 1 FROM InterfaceComponent WHERE (Name Like 'Monitor') AND Start=1)
	SELECT TOP 1 @InterfaceInstanceID=InterfaceInstanceID FROM InterfaceComponent WHERE (Name Like 'Monitor') AND Start=1 ORDER BY InterfaceInstanceID
ELSE
	SELECT TOP 1 @InterfaceInstanceID=InterfaceInstanceID FROM InterfaceInstance WHERE (Description Like 'RobotLoader%')


IF NOT EXISTS (SELECT TOP 1 1 FROM MonitorJob WHERE (InterfaceInstanceID=@InterfaceInstanceID) AND (Description Like @JobDescription))
    INSERT INTO MonitorJob (InterfaceInstanceID, Description, Detail, MonitorScheduleID, NextRun, LastRun, LastRun_StatusID, Active)
        VALUES (@InterfaceInstanceID, @JobDescription, @JobDetail, @MonitorScheduleID, DATEADD(hh, 1, @now), @now, 0, 1)
		 
        
SELECT @MonitorJobID=MonitorJobID FROM MonitorJob WHERE (InterfaceInstanceID=@InterfaceInstanceID) AND (Description Like @JobDescription)

IF (@MonitorJobID IS NOT NULL) AND 
   (@RoutineID    IS NOT NULL) AND 
    NOT EXISTS(SELECT TOP 1 1 FROM MonitorStep WHERE (MonitorJobID=@MonitorJobID) AND (Description Like @JobDescription))
    INSERT INTO MonitorStep (MonitorJobID, StepOrder, Description, Detail, RoutineID, FailureTransformPath, SuccessTransformPath, Active)
        VALUES (@MonitorJobID, 1, @JobDescription, @JobDetail, @RoutineID, null, null, 1)
GO
	
--Add to Version Log
INSERT VersionLog ([Type], [Description], [Date]) SELECT 'Config', 'Robot Loader Interface configuration script.sql (v11)', GETDATE()
GO
