/*
 * update MSL36 release description
 */
 update taxonomy_node set
 -- select notes, (case when notes='EC 52, Online meeting, October 2020; Email ratification March 2021 (MSL #36)' then '=' else '<>' end),
	notes='EC 52, Online meeting, October 2020; Email ratification March 2021 (MSL #36)'
from taxonomy_node
 where tree_id = taxnode_id
 and msl_release_num = 36
 and notes <> 'EC 52, Online meeting, October 2020; Email ratification March 2021 (MSL #36)'

