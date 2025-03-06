
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[count_accents]( 
	@string  AS VARCHAR(max)  -- string to look in
)
RETURNS int
	-- returns the number of accented chartacters
	-- 0 if none are found. 
AS
BEGIN
	-- start at the beginning
	DECLARE @cur_pos AS INT
	SET @cur_pos = 1
	DECLARE @count AS INT
	SET @count = 0
	-- walk backwards, one char at a time
	while @cur_pos <= len(@string)
	BEGIN
		-- check this character
		IF ASCII( SUBSTRING(@string,@cur_pos,1)) > 127
			-- found one - all done
			SET @count = @count+1
		
		-- move back one char
		SET @cur_pos = @cur_pos+1
	END

	RETURN @count
END
/*
print 'testing...'
print '1 = '+rtrim(dbo.count_accents('Wadell, Göran'))
print '2 = '+rtrim(dbo.count_accents('Wadell, Göran & Harrach, Balázs''s'))
*/

GO

