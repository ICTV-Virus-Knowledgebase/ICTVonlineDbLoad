
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[VMR_accessionsStripPrefixesAndConvertToCSV]
(
    @inputString VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
--
-- take [segment:]accession lists from VMR and convert them to CSV of accessions that we can use in NCBI queries
--
-- used by: VIEW [vmr_export]
--
/*
 -- test
 DECLARE @inp varchar(500)
 DECLARE @out varchar(500)

 SET @inp='name1:value1;name2:value2;value3';set @out='value1,value2,value3'
 SELECT [in]=@inp,[out]=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp),passFail=(case when @out=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp) then 'pass' else 'fail' end)

 SET @inp='name1: value1; name2:value2;    value3';set @out='value1,value2,value3'
 SELECT [in]=@inp, [out]=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp),passFail=(case when @out=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp) then 'pass' else 'fail' end)

 SET @inp='name1: value1;;; name2:value2;    value3';set @out='value1,value2,value3'
 SELECT [in]=@inp, [out]=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp),passFail=(case when @out=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp) then 'pass' else 'fail' end)

 SET @inp='name1:value1(5555..53023);name2:value2'; SET @out='value1,value2'
 SELECT [in]=@inp, [out]=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp),passFail=(case when @out=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp) then 'pass' else 'fail' end)

  SET @inp=';'; SET @out=''
 SELECT [in]=@inp, [out]=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp),passFail=(case when @out=dbo.VMR_accessionsStripPrefixesAndConvertToCSV(@inp) then 'pass' else 'fail' end)

*/
BEGIN
    DECLARE @outputString VARCHAR(MAX) = ''
    DECLARE @position INT = 0
    DECLARE @currentValue VARCHAR(MAX)
    
	-- remove all spaces
	SET @inputString = replace(@inputString,' ','')

    -- Loop through each value in the semicolon-separated list
    WHILE CHARINDEX(';', @inputString, @position + 1) > 0 OR LEN(@inputString) > 0
    BEGIN
        -- Extract each semicolon-separated part
        SET @currentValue = CASE 
            WHEN CHARINDEX(';', @inputString, @position + 1) > 0 THEN LEFT(@inputString, CHARINDEX(';', @inputString, @position + 1) - 1)
            ELSE @inputString
        END
        
        -- If there is a colon, remove the part before the colon (the prefix)
        IF CHARINDEX(':', @currentValue) > 0
        BEGIN
            SET @currentValue = SUBSTRING(@currentValue, CHARINDEX(':', @currentValue) + 1, LEN(@currentValue))
        END

        -- If there is a "(", remove the part after the "(" (the location)
        IF CHARINDEX('(', @currentValue) > 0
        BEGIN
            SET @currentValue = SUBSTRING(@currentValue, 1,CHARINDEX('(', @currentValue) - 1)
        END

        -- Append the value to the output string, if it is not empty
        if LEN(@currentValue)>0 BEGIN
			SET @outputString = @outputString + @currentValue + ','
		END

        -- Remove the processed value from the input string
        SET @inputString = STUFF(@inputString, 1, CHARINDEX(';', @inputString + ';'), '')
    END

    -- Remove the trailing comma
    IF LEN(@outputString) > 0
    BEGIN
        SET @outputString = LEFT(@outputString, LEN(@outputString) - 1)
    END
    
    RETURN @outputString
END
GO

