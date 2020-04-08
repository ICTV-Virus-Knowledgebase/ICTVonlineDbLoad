--
-- replace old taxonomy_node with new, extended one
--

EXEC dbo.refresh_views
exec sp_recompile 'taxonomy_node' -- so the SP and TR's get recompile
exec sp_recompile 'taxonomy_node_delta' -- so the SP and TR's get recompile
exec sp_recompile 'taxonomy_node_merge_split' -- so the SP and TR's get recompile
-- think this is obsolete
--exec sp_recompile 'taxonomy_node_merge' -- so the SP and TR's get recompile
