-- taxonomy_node
CREATE INDEX idx_taxonomy_node_parent_level_tree ON taxonomy_node (parent_id, level_id, tree_id);
CREATE INDEX idx_taxonomy_node_taxnode_tree ON taxonomy_node (taxnode_id, tree_id);
CREATE INDEX idx_taxonomy_node_tree_level ON taxonomy_node (tree_id, level_id);
CREATE INDEX idx_node_hidden_msl_name_treelevel ON taxonomy_node (is_hidden, msl_release_num, name, tree_id, level_id);
CREATE INDEX idx_tn_name ON taxonomy_node (name);
CREATE INDEX idx_tn_name_mslrelease ON taxonomy_node (name, msl_release_num);
CREATE INDEX idx_tn_tree_id ON taxonomy_node (tree_id);

-- taxonomy_molecule
CREATE INDEX abbrev ON taxonomy_molecule (abbrev);

-- taxonomy_genome_coverage
CREATE INDEX name ON taxonomy_genome_coverage (name);

-- taxonomy_node_merge_split
CREATE INDEX taxonomy_node_merge_split_next_ictv_id_IDX ON taxonomy_node_merge_split (next_ictv_id);
CREATE INDEX taxonomy_node_merge_split_prev_ictv_id_IDX ON taxonomy_node_merge_split (prev_ictv_id);
