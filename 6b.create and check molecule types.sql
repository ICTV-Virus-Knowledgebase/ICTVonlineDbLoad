--
-- add new molecule types
--
-- insert the missing molecules
--insert into taxonomy_molecule (id,abbrev, name) values ( 13, 'dsDNA; ssDNA', 'DNA - some taxa double stranded, some taxa single standed')


-- check molecule abbreves
select 
	dest_molecule
	,(select id from taxonomy_molecule tm where tm.abbrev = dest_molecule) as id
	,count(*) as usage_ct
	, case when count(*) is null then 'ERROR: misssing molecule' else '' end as problem
from load_next_msl
where dest_molecule is not null
group by dest_molecule
	