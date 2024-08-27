USE [ICTVonline]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[vgd_strrchr]( 
	@targets AS VARCHAR(255), -- characters to look for
	@string  AS VARCHAR(max)  -- string to look in
)
RETURNS int
	-- returns last (right most) occurance in STRING 
	-- of any character in targets.
	-- 0 if none are found. 
AS
BEGIN
	-- start at the end
	DECLARE @cur_pos AS INT
	SET @cur_pos = LEN(@string)
	
	-- walk backwards, one char at a time
	while @cur_pos > 0
	BEGIN
		-- check this character
		IF CHARINDEX( SUBSTRING(@string,@cur_pos,1), @targets) > 0
			-- found one - all done
			BREAK
		
		-- move back one char
		SET @cur_pos = @cur_pos-1
	END

	RETURN @cur_pos
END
/*
print 'testing...'
print '6 = ' + rtrim(dbo.vgd_strrchr(' ', 'hello world'))
print '7 = ' + rtrim(dbo.vgd_strrchr(' w', 'hello world'))
print '0 = ' + rtrim(dbo.vgd_strrchr('xy', 'hello world'))
*/
GO
