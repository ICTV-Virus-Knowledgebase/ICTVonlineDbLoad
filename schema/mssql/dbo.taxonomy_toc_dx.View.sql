
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[taxonomy_toc_dx] as

select 
	t1.*
	, tree_id_delta = t1.tree_id - t2.tree_id
	, prev_tree_id=t2.tree_id
	, prev_msl=t2.msl_release_num
from taxonomy_toc t1
join taxonomy_toc t2 on t2.msl_release_num = t1.msl_release_num - 1
GO

