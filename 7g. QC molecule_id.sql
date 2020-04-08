--
-- 7g QC molecule type
--


select report='nodes with redundant molecule_type'
	, rank=l.name
	, explicitMol=m.abbrev
	, flag=(case 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then '>>dup>>' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'overrides' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
	end)
	, inherMol=mi.abbrev
	, n.lineage
from taxonomy_node n
join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_level l on l.id = n.level_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mi on mi.id = p.inher_molecule_id
where n.tree_id = dbo.get_tree_id_of_latest_msl()
and n.taxnode_id in (
	-- adding the outter select TOP keeps the IN() operator from hanging....
	select top 10000 taxnode_id from
	(
		-- all taxa w/ a mol type and their ancestors
		select --top 10000  
			distinct a.taxnode_id--, a.lineage, srcL=t.lineage
		from taxonomy_node a
		join taxonomy_node t on t.left_idx between a.left_idx and a.right_idx and t.tree_id = a.tree_id
		where t.tree_id =  dbo.get_tree_id_of_latest_msl()
		--and t.name='Caraparu orthobunyavirus'
		--order by a.left_idx
		-- all species w/o an inheritd mol type
		and  t.molecule_id is not null
	
		union 
		--
		-- all nodes with explicit mol types that match their inher type
		--
		select distinct xm.taxnode_id  -- select xm.taxnode_id, mol=xm.molecule_id, inherMol= xm.inher_molecule_id, parentMol=p.inher_molecule_id, xm.lineage
		from taxonomy_node xm
		join taxonomy_node p on p.taxnode_id = xm.parent_id
		where xm.tree_id =  dbo.get_tree_id_of_latest_msl()
		and xm.molecule_id is not null and p.inher_molecule_id is not null 
		and xm.molecule_id = p.inher_molecule_id
	) as src
)
order by n.left_idx

select report='nodes with OVER-RIDE molecule_type' 
	, rank=l.name
	, explicitMol=m.abbrev
	, flag=(case 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then '>>dup>>' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'overrides' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
	end)
	, inherMol=mi.abbrev
	, n.lineage
from taxonomy_node n
join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_level l on l.id = n.level_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mi on mi.id = p.inher_molecule_id
where n.tree_id = dbo.get_tree_id_of_latest_msl()
and n.taxnode_id in (
	-- all nodes that override their inherited molecule_id
	select top 4000
		 n.taxnode_id  -- select xm.taxnode_id, mol=xm.molecule_id, inherMol= xm.inher_molecule_id, parentMol=p.inher_molecule_id, xm.lineage
	from taxonomy_node n
	join taxonomy_node xm on xm.tree_id = n.tree_id and xm.left_idx between n.left_idx and n.right_idx
	join taxonomy_node p on p.taxnode_id = xm.parent_id
	where xm.tree_id =  dbo.get_tree_id_of_latest_msl()
	and xm.molecule_id is not null and p.inher_molecule_id is not null 
	and xm.molecule_id <> p.inher_molecule_id
	group by n.taxnode_id
)
order by n.left_idx

select report='nodes with interesting  molecule_type situtations (dup, override, missing)'
	, n.taxnode_id
	, rank=l.name
	, explicitMol=m.abbrev
	, flag=(case 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then '>>dup>>' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'overrides' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
	end)
	, inherMol=mi.abbrev
	, n.lineage
from taxonomy_node n
join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_level l on l.id = n.level_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mi on mi.id = p.inher_molecule_id
where n.tree_id = dbo.get_tree_id_of_latest_msl()
and n.taxnode_id in (
	-- adding the outter select TOP keeps the IN() operator from hanging....
	select top 10000 taxnode_id from
	(
		-- all taxa w/ a mol type and their ancestors
		select --top 10000  
			distinct a.taxnode_id--, a.lineage, srcL=t.lineage
		from taxonomy_node a
		join taxonomy_node t on t.left_idx between a.left_idx and a.right_idx and t.tree_id = a.tree_id
		where t.tree_id =  dbo.get_tree_id_of_latest_msl()
		and  (
			-- mol explicitly set
			t.molecule_id is not null
			or
			-- genus, no molecule type
			t.inher_molecule_id is null and t.level_id = 500 
	)

	) as src
)
order by n.left_idx


select report=' lineages with Unassigned  molecule_type situtations (dup, override, missing)'
	, rank=l.name
	, explicitMol=m.abbrev
	, flag=(case 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id = p.inher_molecule_id then '>>dup>>' 
		when n.molecule_id is not null and p.inher_molecule_id is not null and n.molecule_id <> p.inher_molecule_id then 'overrides' 
		when n.inher_molecule_id is null and  n.level_id>=500 then '!MISSING!'
	end)
	, inherMol=mi.abbrev
	, n.lineage
from taxonomy_node n
join taxonomy_node p on p.taxnode_id = n.parent_id
left outer join taxonomy_level l on l.id = n.level_id
left outer join taxonomy_molecule m on m.id = n.molecule_id
left outer join taxonomy_molecule mi on mi.id = p.inher_molecule_id
where n.tree_id = dbo.get_tree_id_of_latest_msl()
and n.taxnode_id in (
	-- adding the outter select TOP keeps the IN() operator from hanging....
	select top 10000 taxnode_id from
	(
		-- all taxa w/ a mol type and their ancestors
		select --top 10000  
			distinct a.taxnode_id--, a.lineage, srcL=t.lineage
		from taxonomy_node a
		join taxonomy_node t on  t.tree_id = a.tree_id and ( t.left_idx between a.left_idx and a.right_idx or a.left_idx between t.left_idx and t.right_idx)
		where t.tree_id =  dbo.get_tree_id_of_latest_msl()
		and  (
			-- mol explicitly set
			t.molecule_id in (0,8) -- Unassigned / Viroid
		)
	) as src
)
order by n.left_idx