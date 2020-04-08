--
-- NUKE MSL=34 from taxonomy_node (so we can try again)
--
-- !! WARNING: takes > 20 minutes to run !!!
-- BETTER MAKE A BACKUP INSTEAD

select msl_release_num, count(*) from taxonomy_node where msl_release_num in (select distinct dest_msl_release_num from load_next_msl) group by msl_release_num
delete from taxonomy_node where msl_release_num = 34 --in (select distinct dest_msl_release_num from load_next_msl)