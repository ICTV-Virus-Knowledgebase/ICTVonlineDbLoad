/*
 * add proposal for removal of type species
 * 
 * https://github.com/rusalkaguy/ICTVonlineDbLoad/issues/5
 *
 * use “2020.001G.R.Abolish_type_species.pdf”
 */

DECLARE @prop varchar(500); SET @prop='2020.001G.R.Abolish_type_species.pdf'

--
-- new and split are on MSL36.in_filename.
-- but "new" wont have an is_ref=1 
-- and there are no "splits" between MSL35-36
-- 
-- so can just handle MSL35.out_filename
--
update taxonomy_node set
	select taxnode_id, tree_id, is_ref, out_filename, 
	out_filename = isnull(out_filename+';','')+@prop
from taxonomy_node 
where msl_release_num = 35
and is_ref=1
-- only add it once
and (out_filename is null or out_filename not like '%'+@prop+'%')

--
print 'Go update SP rebiuld_delta_nodes'
--
exec rebuild_delta_nodes NULL -- default is current MSL

-- check that is_now_type is back, with proposal doc, and alway goes to -1
select top 500 * from taxonomy_node_dx where prev_tags like '%type%' and msl_release_num = 36

select out_filename from taxonomy_node where taxnode_id in (201900228)
select ct=count(*) from taxonomy_node_delta where proposal like '%Abolish_type_species%' 