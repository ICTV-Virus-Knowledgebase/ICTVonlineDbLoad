USE [ICTVonlnie34]
GO
/****** Object:  View [dbo].[view_membership_committee_with_submembers]    Script Date: 4/24/2020 3:40:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--
-- Generate complete membership list for any SC
--
CREATE VIEW [dbo].[view_membership_committee_with_submembers]
AS 
SELECT
	-- parent committee (WHERE on this)
	target_committee_id = target.committee_id
	, target_committee = target.display_name
	-- info on child committees (WHERE on this)
	, hit_depth = hit.node_depth - target.node_depth
	-- actual membership info
	, msx.*
FROM committee target
JOIN view_membership_x msx ON msx.left_idx BETWEEN target.left_idx and target.right_idx
-- use this to compute depth of child
JOIN committee hit ON (
	hit.committee_id = msx.committee_id
)
/*
-- test
WHERE target.display_name like 'Executive Committee'
and hit.node_depth - target.node_depth <= 1 -- hit_depth: direct and immediate kids
ORDER BY msx.display_order desc
	, msx.position desc, msx.committee, msx.last_name, msx.first_name
*/
/*
WHERE target.display_name = 'Plant Virus Subcommittee'
ORDER BY msx.display_order desc
	, msx.position desc, msx.committee
*/

GO
