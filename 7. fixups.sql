--
-- manual fixups
--


-- ***** MSL 32 ******************************************************************************************************************************************

-- --------------------------------------------------------------------------------------
-- 
-- SCAN for orphan 'Unassigned' - NOT WORKING
-- Ex: MSL30, Tymovirales > Betaflexiviridae > [Unassigned] > Unassigned : has no kids
--
-- --------------------------------------------------------------------------------------
select p.msl_release_num, p.taxnode_id, p.ictv_id, p.level_id, p.is_hidden, p.lineage,p.notes, childCount=(p.right_idx-p.left_idx-1)/2
from taxonomy_node as p
left outer join taxonomy_node as c on c.parent_id = p.taxnode_id
where p.msl_release_num is not null
and p.level_id < 600
and p.is_deleted = 0
and not (
	-- Elliot: prior to 1999, species were not recognized. So higher-level taxa were established that did not formally contain species. 
	-- Many times they were populated with "viruses" and that is what was listed in the database. 
	-- But occasionally, no virus was designated that would have been assigned to the higher-level taxon. Hence these two taxa with no species/virus
	--p.lineage in ('')--('Unassigned;Poxviridae;Unassigned;Entomopoxvirus','Unassigned;Hepadnaviridae')
	p.notes like '%known empty taxon!%' and p.notes is not null
)
group by p.msl_release_num, p.taxnode_id, p.ictv_id, p.level_id, p.is_hidden,  p.lineage, p.notes, p.left_idx, p.right_idx
having count(c.taxnode_id) = 0 
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7; empty taxa found', 18, 1) else print('PASS - no empty taxa')


--
-- WHY Unassigned;Metaviridae;Unassigned;Semotivirus NOT MOVED TO Ortervirales;Belpaoviridae;Unassigned;Semotivirus 
--
select distinct n.* 
from [taxonomy_node] n 
join [taxonomy_node] t on (
	 --t.name in ('Aspiviridae') 
	 t.lineage in ('Ortervirales;Belpaoviridae;Unassigned','Unassigned;Solemoviridae;Unassigned')
) AND n.left_idx between t.left_idx and t.right_idx and n.tree_id = t.tree_id
order by n.left_idx

select * from [taxonomy_node] where level_id is null and tree_id = (select max(tree_id) from taxonomy_node)

-- 
-- clean up messes with Aspiviridae rename
--
update taxonomy_node set 
--select lineage, *, 
parent_id = 20173945 -- original Unassigned;Aspiviridae;Unassigned;Ophiovirus that came from renaming the family
from taxonomy_node
where tree_id=20170000 and parent_id = 20176012 -- new, badly formed genus that was implicitly created.

delete 
-- select * 
from taxonomy_node
where taxnode_id in (20176013, 20176012)

update taxonomy_node set
--select lineage, *, 
level_id = 400 -- sub family
, is_hidden = 1 
from taxonomy_node
where tree_id=20170000 and lineage in ('Ortervirales;Belpaoviridae;Unassigned','Unassigned;Solemoviridae;Unassigned') -- new, badly formed subfamilies that was implicitly created.

--
-- changes of level
--
select src_level, dest_level, * 
from load_next_msl 
where ( len(src_lineage)-len(replace(src_lineage,';',''))) <> ( len(dest_target)-len(replace(dest_target,';','')))
and (dest_in_change not in ('new') or dest_in_change is null) and (src_out_change not in ('abolish') or src_out_change is null)
if @@ROWCOUNT > 0  raiserror('ERROR fixups 7; taxa change level badly', 18, 1) else print('PASS - no bad level changes')

--
-- DELETE 'Unassigned' subfamilies/genera with prejudice
--
-- RUN until 0 rows deleted (2x) - deleting an unassigned genus and leave an unassigned subfamily empty!
--
delete from taxonomy_node where taxnode_id in 
(
	select p.taxnode_id
	--select p.msl_release_num, p.taxnode_id, p.level_id, p.is_hidden, p.lineage
	from taxonomy_node as p
	left outer join taxonomy_node as c on c.parent_id = p.taxnode_id
	where p.msl_release_num is not null
	and (
		(p.level_id = 400 and p.is_hidden = 1) -- subfamily
		or
		(p.name = 'Unassigned')
	)
	group by p.msl_release_num, p.taxnode_id, p.level_id, p.is_hidden,  p.lineage
	having count(c.taxnode_id) = 0 
)

/*
-- query detail on children for a taxon across the years.
select tree=msl_release_num, lineage, * from taxonomy_node
where lineage like 'Unassigned;Hepadnaviridae%' 
order by tree_id, left_idx

-- query for details on a particular taxon's children
select t.lineage as 'target', tn.lineage as 'hit', tn.*
from taxonomy_node t
left outer join taxonomy_node as tn on tn.left_idx between t.left_idx and t.right_idx and tn.tree_id = t.tree_id
where t.taxnode_id =20162972
order by tn.left_idx

*/


-- -------------------------------------------------------------------
-- lowercase 'unassigned'
-- -------------------------------------------------------------------
update taxonomy_node set 
	--select ascii(name), name, 
	name = 'Unassigned' 
from taxonomy_node
where name = 'unassigned' and ascii(name)=117 -- lowercase U

-- -------------------------------------------------------------------
-- 3.	The ‘Unassigned’ designation when used for genera is sometimes upper, sometimes lower case
-- -------------------------------------------------------------------
update taxonomy_node set
	name = NULL
where taxnode_id in (
	select	-- select *,
		taxnode_id
	from taxonomy_node 
	where level_id=400 -- subfamily
	and is_hidden = 1 and name = 'unassigned'
)
-- -------------------------------------------------------------------
-- 1.	See extra line 2974 of your spreadsheet. 
-- CTRL-ENTER introduced in MSL30. Fixes 2 rows.
-- -------------------------------------------------------------------
update taxonomy_node set 
	-- select genbank_accession_csv, replace(genbank_accession_csv, char(10), ' '),
	genbank_accession_csv=replace(genbank_accession_csv, char(10), ', ')
from taxonomy_node 
where genbank_accession_csv like '%'+char(10)+'%' 





--
-- clean up quoted proposal filenames! ARG - shoudln't get this far!!!!
--
select 'quoted proposal name' as problem 
	, msl_release_num, lineage, in_filename, in_change, out_filename, out_change
from taxonomy_node n
where in_filename like '"%"'
or out_filename like '"%"'
	
update taxonomy_node set
	in_filename = REPLACE(in_filename,'"','')
where in_filename like '"%"'

update taxonomy_node set
	out_filename = REPLACE(out_filename,'"','')
where out_filename like '"%"'

update taxonomy_node_delta set
	proposal = REPLACE(proposal,'"','')
where proposal like '"%"'


--
-- add .pdf to existing filenames that lack an extension of .pdf or .zip
-- 
update taxonomy_node set 
--select *,
	in_filename = in_filename + '.pdf'
from taxonomy_node 
where in_filename is not null and in_filename not like '%.pdf'  and in_filename not like '%.zip'

update taxonomy_node set 
--select *,
	out_filename = out_filename + '.pdf'
from taxonomy_node 
where out_filename is not null and out_filename not like '%.pdf'  and out_filename not like '%.zip'

update taxonomy_node_delta set
-- select *,
	proposal = proposal + '.pdf'
from taxonomy_node_delta
where proposal is not null and proposal not like '%.pdf'  and proposal not like '%.zip'

