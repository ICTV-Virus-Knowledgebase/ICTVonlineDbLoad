USE [ICTVonline]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_simplify_molecule_id_settings]
	@msl int = NULL-- delete related deltas first?
AS
	-- declare @msl int; set @msl = NULL -- DEBUG
	declare @tree_id int
	select @tree_id=MAX(tree_id), @msl=max(msl_release_num) from taxonomy_toc where tree_id=@msl or msl_release_num=@msl or (msl_release_num is not null and @msl is null)
	select [TARGET MSL]=@msl, [TARGET TREE]=@tree_id
	print '@msl='+rtrim(@msl)

	
--
-- push molecule_id to parent ranks if entire subtree is homogeneous.
--
WHILE(1=1) BEGIN -- run until 0 rows change
	--
	-- do work: unset redundent molecule_id's
	--
	update taxonomy_node set
	--DEBUG: declare @msl int; set @msl = dbo.udf_getMSL(NULL); select 	taxonomy_node.level_id, taxonomy_node.lineage, 
		molecule_id = src.consensus_mol_id
	from taxonomy_node 
	join (
		--
		-- list of nodes, with NO molecule setting, whose entire set of sub-taxa all have the same molecule setting
		--
		select 
			top 1000000 -- so we can leave the order by in for debugging
			t.left_idx, t.taxnode_id, t.[rank], t.lineage, t.molecule_id, t.inher_molecule_id
			, n_ct=count(n.taxnode_id), im_ct=count(n.inher_molecule_id), im_min=min(n.inher_molecule), im_max=max(n.inher_molecule), consensus_mol_id=min(n.inher_molecule_id)
		from taxonomy_node_names t
		join taxonomy_node_names n on n.left_idx between t.left_idx and t.right_idx and n.tree_id =t.tree_id and n.taxnode_id <> t.taxnode_id
		where t.msl_release_num = @msl 
		and (
				-- ORDER or below, outside Bunyavirales
				(t.level_id >= 200 and (t.[order] <> 'Bunyavirales' or t.[order] is null)
				) or
				-- ORDER or below, outside Bunyavirales
				(t.level_id >= 500 and t.[order] = 'Bunyavirales'  )
		)
		group by t.left_idx, t.taxnode_id, t.[rank], t.lineage, t.molecule_id, t.inher_molecule_id
		having  count(n.taxnode_id)=count(n.inher_molecule_id) 
		and min(n.inher_molecule_id)=max(n.inher_molecule_id) 
		and  (
			t.molecule_id is null
			and (
				t.inher_molecule_id is null 
				or 
				-- this allows us to creap up on Unassigned and Viriod, at least the child of the taxon it is set on.
				t.inher_molecule_id <> min(n.inher_molecule_id)
			)
		)
		order by left_idx
	) as src 
	on src.taxnode_id = taxonomy_node.taxnode_id

	-- stop when done
	IF(@@ROWCOUNT = 0) BREAK

END

-- 
-- clean up redundant mol_id settings (run once)
--

WHILE(1=1) BEGIN
	--
	-- do work: unset redundent molecule_id's
	--
	update taxonomy_node set
	-- DEBUG: declare @msl int; set @msl = dbo.udf_getMSL(NULL); select taxonomy_node.lineage, taxonomy_node.molecule_id, p.lineage, p.inher_molecule_id,
		molecule_id = NULL
	from taxonomy_node 
	join taxonomy_node p on p.taxnode_id = taxonomy_node.parent_id
	where taxonomy_node.molecule_id = p.inher_molecule_id
	and  taxonomy_node.msl_release_num=@msl 
	--print @@ROWCOUNT

	-- stop when done
	IF(@@ROWCOUNT = 0) BREAK

END

	/*
	-- TEST
	--
	exec sp_simplify_molecule_id_settings
	*/
GO

