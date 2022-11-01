ALTER procedure [dbo].[NCBI_linkout_ft_export]
 	 @msl int = NULL,
	 @newline varchar(10) =NULL
AS

-- debug DECLARES for args
-- declare @msl int; declare @newline varchar(10) 

DECLARE @URL varchar(500); 
DECLARE @LINKOUT_PROVIDER_ID varchar(10); 

-- constants for ICTV
SET @LINKOUT_PROVIDER_ID = '7640'
SET @URL = 'https://ictv.global/taxonomy/taxondetails?taxnode_id='

-- get most recent MSL, if not specified in args
set @msl = (select isnull(@msl,max(msl_release_num)) from taxonomy_node)

-- use WINDOWS line terminators, if not specified in args
-- The Mac, by default, uses a single carriage return (<CR>), represented as \r. 
-- Unix, on the other hand, uses a single linefeed (<LF>), \n. 
-- Windows goes one step further and uses both, creating a (<CRLF>) combination, \r\n.
--set @newline = isnull(@newline,char(13)) -- Mac (\r)
---set @newline = isnull(@newline,char(10)) -- Linux (\n)
set @newline = isnull(@newline,char(13)+char(10)) -- Windows
--set @newline = '|' -- map after download


print 'MSL: ' + @newline + rtrim(@msl)


select t
from (
--
-- print the header that identifies us as a linkout provider
--
-- this gives
--     our provider id (prid:)
--     our base URL, to which the record key will be appended
--
select 
	left_idx=NULL, msl_release_num=NULL, t=
	'---------------------------------------------------------------' + @newline
	+ 'prid:   '+ @LINKOUT_PROVIDER_ID + @newline
	+ 'dbase:  taxonomy' + @newline
	+ 'stype:  taxonomy/phylogenetic' + @newline
	+ '!base:  '+ @URL + @newline
	+ '---------------------------------------------------------------' 
union all
-- 
-- export the actual taxa
-- 
-- use "left_idx" as a unique "row number" (arbitrary)
-- the taxon name is the key for the linkout
-- the ictv_id is the ID they return to us
select 
	max(left_idx), max(msl_release_num), t=
	'linkid:   '+ rtrim(max(taxnode_id)) + @newline -- need "rownum!"
	+ 'query:  '+name+' [name]' + @newline
	+ 'base:  &base;' + @newline
	+ 'rule:  '+ rtrim(max(taxnode_id)) + @newline
	+ 'name:  '+name + @newline
	+'---------------------------------------------------------------' 
from taxonomy_node_names taxa
where msl_release_num <= @msl -- latest MSL
 -- skip internal nodes: virtual subfamilies, etc
and is_deleted = 0 and is_hidden=0 and is_obsolete=0
and name is not null and name <> 'Unassigned'
group by name 
) as src 
order by  src.left_idx

/*
--
-- test
-- 
exec [NCBI_linkout_ft_export] 1
exec [NCBI_linkout_ft_export] 37, '|'

*/

GO

