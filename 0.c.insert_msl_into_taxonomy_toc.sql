/*
 * register our new MSL into taxonomy_toc
 *
 * defines MSL & tree_id 
 *
 */

 select top 5 m='5 most recent hightest msls', * 
 from taxonomy_toc_dx
 order by msl_release_num desc


 insert into taxonomy_toc (msl_release_num, tree_id) values (35, 2019*100*1000)