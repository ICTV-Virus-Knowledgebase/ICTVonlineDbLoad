ALTER TABLE dbo.taxonomy_node ADD CONSTRAIN
	[FK_taxonomy_node_taxonomy_node-realm_id] FOREIGN KEY
	(
	realm_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-subrealm_id] FOREIGN KEY
	(
	subrealm_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-kingdom_id] FOREIGN KEY
	(
	kingdom_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-subgenus_id] FOREIGN KEY
	(
	subgenus_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-subkingdom_id] FOREIGN KEY
	(
	subkingdom_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-phylum_id] FOREIGN KEY
	(
	phylum_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-subphylum_id] FOREIGN KEY
	(
	subphylum_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-class_id] FOREIGN KEY
	(
	class_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-subclass_id] FOREIGN KEY
	(
	subclass_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.taxonomy_node ADD CONSTRAINT
	[FK_taxonomy_node_taxonomy_node-suborder_id] FOREIGN KEY
	(
	suborder_id
	) REFERENCES dbo.taxonomy_node
	(
	taxnode_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO