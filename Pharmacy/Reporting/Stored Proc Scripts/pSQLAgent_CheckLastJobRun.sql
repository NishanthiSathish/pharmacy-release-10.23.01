if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[pSQLAgent_CheckLastJobRun]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[pSQLAgent_CheckLastJobRun]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE [dbo].[pSQLAgent_CheckLastJobRun]
 
  -- Individual job parameters  
  @job_name                   sysname          = NULL,  -- If provided should NOT also provide job_id  
  @job_id                     UNIQUEIDENTIFIER = NULL   -- If provided should NOT also provide job_name  
  

AS  
BEGIN  
  DECLARE @retval          INT  
  DECLARE @job_id_as_char  VARCHAR(36)  
  Declare @Steps_Error     Int
  Declare @Message         VarChar (255)
    
  SET NOCOUNT ON  
  
  -- Remove any leading/trailing spaces from parameters 
  SELECT @job_name         = LTRIM(RTRIM(@job_name))  
  
  -- Turn [nullable] empty string parameters into NULLs  
  IF (@job_name         = N'') SELECT @job_name = NULL  
  
  IF ((@job_id IS NOT NULL) or (@job_name IS NOT NULL))  
  BEGIN  
    EXECUTE @retval = msdb.dbo.sp_verify_job_identifiers '@job_name',  
                                                '@job_id',  
                                                 @job_name OUTPUT,  
                                                 @job_id   OUTPUT,  
                                                 'NO_TEST'
    IF (@retval <> 0)  
      RETURN(1) -- Failure  
  END  
  
  SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)  
  
  -- The caller must supply EITHER job name or Job ID
  IF (@job_name IS NULL) and (@job_id IS NULL)  
     BEGIN  
       RAISERROR(14294, -1, -1, '@job_id', '@job_name')  
       RETURN(1) -- Failure  
     END  
  
  -- Set Job Name if Job ID passed
  If (@job_name IS NULL) 
     Select top 1 @job_name = [name] from msdb.dbo.sysjobs where job_id = @job_id
 
  -- Check If any errors - Link SQL Agent Jobs to Steps to Last Run History
  select sj.[name], SH.step_id, SH.run_date, SH.run_time, SH.sql_message_id, SH.sql_message_id, SH.[message]
  
    From msdb.dbo.sysjobs       SJ  
    Join msdb.dbo.sysjobsteps   SS  on SJ.job_id = SS.job_id 
    Join msdb.dbo.sysjobhistory SH  on SS.job_id = SH.job_id and ss.step_id = SH.step_id and SS.last_run_date = SH.run_date and SS.last_run_time = SH.run_time
  
  where  @job_name = SJ.name and  SH.sql_severity <> 0 
         and (SS.command not like 'exec pSqlAgent%' and SH.sql_message_id <> 50000) -- Ignore itself

  Set @Steps_Error = @@ROWCOUNT

  if  @Steps_Error > 0
     Begin 
        Set @Message = 'Job ' + @Job_Name + 
                       ' Failed, Number of Steps in Error: ' + 
                       cast(@Steps_error as varchar(5)) +
                       ' - Please check Job History'

        RAISERROR(@Message, 16, 1)
     End
  Else  
     Begin 
       Set @Message = 'Job ' + @Job_Name + 
                       ' was successful, No steps in Error'
       Print @Message
     End       

  RETURN(0) -- Success  
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

