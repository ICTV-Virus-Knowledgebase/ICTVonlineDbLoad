-- -----------------------------------------------------------------------------
--
-- build deltas from in_out changes + {name, lineage, is_ref} changes
--
-- RUN TIME: 
--       on MSL34b
--   24 seconds on MSL33
-- -----------------------------------------------------------------------------


-- MSL34 3m50s
-- MSL33 0m24s
EXEC [dbo].[rebuild_delta_nodes] NULL -- hits latest MSL automatically.

-- MSL34 0m07s
-- MSL33 0m07s
exec [dbo].[rebuild_node_merge_split]

