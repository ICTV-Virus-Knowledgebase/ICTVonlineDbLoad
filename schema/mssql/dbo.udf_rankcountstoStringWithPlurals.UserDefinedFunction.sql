
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE   FUNCTION [dbo].[udf_rankCountsToStringWithPurals]
(
        @realm_ct as int,
        @subrealm_ct as int,
        @kingdom_ct as int,
        @subkingdom_ct as int,

        @phylum_ct as int,
        @subphylum_ct as int,
        @class_ct as int,
        @subclass_ct as int,

        @order_ct as int,
        @suborder_ct as int,
        @family_ct as int,
        @subfamily_ct as int,

        @genus_ct as int,
        @subgenus_ct as int,

        @species_ct as int
)
RETURNS varchar(500)
AS
BEGIN
	DECLARE @csv varchar(500)
	DECLARE @str varchar(500)

	SET @CSV = (case @realm_ct when 0 then NULL when 1 then '1 realm' else rtrim(@realm_ct)+' realms' end)

	SET @STR = (case @subrealm_ct when 0 then NULL when 1 then '1 subrealm' else rtrim(@subrealm_ct)+' subrealms' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @kingdom_ct when 0 then NULL when 1 then '1 kingdom' else rtrim(@kingdom_ct)+' kingdoms' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @subkingdom_ct when 0 then NULL when 1 then '1 subkingdom' else rtrim(@subkingdom_ct)+' subkingdoms' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @phylum_ct when 0 then NULL when 1 then '1 phylum' else rtrim(@phylum_ct)+' phyla' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @subphylum_ct when 0 then NULL when 1 then '1 subphylum' else rtrim(@subphylum_ct)+' subphyla' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @class_ct when 0 then NULL when 1 then '1 class' else rtrim(@class_ct)+' classes' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @subclass_ct when 0 then NULL when 1 then '1 subclass' else rtrim(@subclass_ct)+' subclasses' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @order_ct when 0 then NULL when 1 then '1 order' else rtrim(@order_ct)+' orders' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @suborder_ct when 0 then NULL when 1 then '1 suborder' else rtrim(@suborder_ct)+' suborders' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @family_ct when 0 then NULL when 1 then '1 family' else rtrim(@family_ct)+' families' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @subfamily_ct when 0 then NULL when 1 then '1 subfamily' else rtrim(@subfamily_ct)+' subfamilies' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @genus_ct when 0 then NULL when 1 then '1 genus' else rtrim(@genus_ct)+' genera' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @subgenus_ct when 0 then NULL when 1 then '1 subgenus' else rtrim(@subgenus_ct)+' subgenera' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)

	SET @STR = (case @species_ct when 0 then NULL when 1 then '1 species' else rtrim(@species_ct)+' species' end)
	SET @CSV = ISNULL(ISNULL(@CSV+', ','')+@STR,@CSV)
	
	RETURN ISNULL(@CSV,'')

END

/*
 * test
 *

select 
	[singular]=dbo.[udf_rankCountsToStringWithPurals](1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1, 1)
	,[plurals]=dbo.[udf_rankCountsToStringWithPurals](2,2,2,2, 2,2,2,2, 2,2,2,2, 2,2, 2)
	,[mixed]=dbo.[udf_rankCountsToStringWithPurals](0,1,2,3, 0,1,2,3, 0,1,2,3, 0,1, 2)

*/
GO

