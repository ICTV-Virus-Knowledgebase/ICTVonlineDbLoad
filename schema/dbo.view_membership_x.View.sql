USE [ICTVonlnie34]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- add "is_flagged"
CREATE VIEW [dbo].[view_membership_x] 
AS
SELECT 
	-- committee
	c.display_name as [committee]
	, c.name as [committee_name]
	, c.type as [committee_type]
	, c.left_idx
	, c.committee_id
	, c.parent_id
	-- member
	, m.*
	-- position
	, p.name as [position]
	, p.position_id
	, p.display_order
	-- membership
	, ms.membership_id
	, is_flagged
FROM membership ms
JOIN member m ON m.member_id = ms.member_id
JOIN position p ON p.position_id = ms.position_id
JOIN committee c ON c.committee_id = p.committee_id
WHERE is_inactive='N'
GO
