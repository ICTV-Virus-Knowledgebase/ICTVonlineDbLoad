USE [ICTVonline33]
GO

UPDATE [dbo].[taxonomy_node]
   SET [is_ref] = 1
  WHERE name = 'Epsilonarterivirus hemcep'
GO
UPDATE [dbo].[taxonomy_node]
   SET [is_ref] = 1
  WHERE name = 'Thetaarterivirus mikelba 1'
GO
UPDATE [dbo].[taxonomy_node]
   SET [is_ref] = 1
  WHERE name = 'Iotaarterivirus kibreg 1'
GO
UPDATE [dbo].[taxonomy_node]
   SET [is_ref] = 1
  WHERE name = 'Betaarterivirus suid 1'
GO


-- -----------------------------------------------------------------------------
-- build deltas from in_out changes + {name, lineage, is_ref} changes
--
-- RUN TIME: 24 seconds on MSL33
-- -----------------------------------------------------------------------------

EXEC [dbo].[rebuild_delta_nodes] NULL -- hits latest MSL automatically.
GO

--
-- QC
--
select * from taxonomy_node where taxnode_id in (20171844	,20181844) --name = 'Epsilonarterivirus hemcep' or ictv_id = 20151195
order by tree_id

select * from taxonomy_node_delta where new_taxid in (select taxnode_id from taxonomy_node where name = 'Epsilonarterivirus hemcep' or ictv_id = 20151195)
