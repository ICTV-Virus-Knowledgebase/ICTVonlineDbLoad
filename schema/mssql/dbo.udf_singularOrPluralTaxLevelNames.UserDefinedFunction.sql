USE [ICTVonline39lmims]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_singularOrPluralTaxLevelNames]
(
	-- Parameter(s)
	@level_count as int,
	@level_id as int
	
)
RETURNS varchar(128)
AS
BEGIN
	DECLARE @level_label AS varchar(128) = (
		CASE 
			WHEN @level_id = 200 AND @level_count = 1 THEN 'Order'
			WHEN @level_id = 200 AND @level_count <> 1 THEN 'Orders'

			WHEN @level_id = 300 AND @level_count = 1 THEN 'Family'
			WHEN @level_id = 300 AND @level_count <> 1 THEN 'Families'

			WHEN @level_id = 400 AND @level_count = 1 THEN 'Subfamily'
			WHEN @level_id = 400 AND @level_count <> 1 THEN 'Subfamilies'

			WHEN @level_id = 500 AND @level_count = 1 THEN 'Genus'
			WHEN @level_id = 500 AND @level_count <> 1 THEN 'Genera'

			WHEN @level_id = 600 THEN 'Species'

			ELSE ''
		END
	);

	DECLARE @result AS varchar(200) = '';
	IF @level_label IS NOT NULL AND @level_label <> ''
		SET @result = cast(@level_count as varchar(3))+' '+@level_label;

	RETURN @result;
END
GO
