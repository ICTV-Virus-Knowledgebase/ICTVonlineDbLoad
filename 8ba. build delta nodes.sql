-- -----------------------------------------------------------------------------
--
-- build deltas from in_out changes + {name, lineage, is_ref} changes
--
-- RUN TIME: 24 seconds on MSL33
-- -----------------------------------------------------------------------------

--begin transaction
EXEC [dbo].[rebuild_delta_nodes] NULL -- hits latest MSL automatically.
-- commit transaction
-- rollback transaction
