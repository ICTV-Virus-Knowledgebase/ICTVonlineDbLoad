
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rebuild_delta_nodes]
	@msl int = NULL-- delete related deltas first?
AS
	-- 20230315 newer version that works with new 
	--	 [is_lineage_updated], [msl] and [tag_csv2]
	-- columns
	exec [rebuild_delta_nodes_2] @msl

	/*
	-- TEST
	exec rebuild_delta_nodes 38
	--
	*/
GO

