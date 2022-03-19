--
-- add new molecule types
--
-- insert the missing molecules
--insert into taxonomy_molecule (id,abbrev, name) values ( 13, 'dsDNA; ssDNA', 'DNA - some taxa double stranded, some taxa single standed')


-- check molecule abbreves
select 
	report='map molecule names to taxonomy_molecule'
	, count(*) as usage_ct
	, molecule
	,molecule_id = isnull(rtrim(tm.id), '--MISSING--')
	, best_guess = guess.abbrev
	, (case when count(*) > 0 and tm.id is null then  'ERROR: misssing molecule' else '' end) as problem
	, proposal_count=count(distinct(proposal))
from load_next_msl
left outer join taxonomy_molecule tm on tm.abbrev = molecule
left outer join taxonomy_molecule guess on guess.abbrev = replace(molecule,' (', '(')
where molecule is not null
group by molecule, tm.id,  guess.abbrev
	
-- report which proposals to change? 
select proposal, molecule, rows=count(*) from load_next_msl where molecule like '%(%)%' group by proposal, molecule order by proposal

-- for refernece
select t='taxonomy_molecule', *  from taxonomy_molecule tm

-- fix ones we can guess
select 
	report='fix molecule abbrev in load_next_msl'
	, molecule
	, best_guess = guess.abbrev
--RUN-- update load_next_msl set molecule = guess.abbrev
from load_next_msl
left outer join taxonomy_molecule tm on tm.abbrev = molecule
left outer join taxonomy_molecule guess on guess.abbrev = replace(molecule,' (', '(')
where molecule	 is NOT null 
and tm.abbrev		IS null
and guess.abbrev is NOT null

-- 