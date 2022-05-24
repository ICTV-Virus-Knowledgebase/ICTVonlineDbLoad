# ICTVonlineDbLoad

ICTVonline - Database Loading "ETL" scripts and database schema

## Schema

Create scripts for the current schema are found in [./schema/](schema/)

See schema documentation: [./schema/README.md](schema/README.md)


## Load Scripts

The current approach for loading 

1. combine all change proposal .xlsx files using [merge_proposal_zips.Rmd](https://github.com/ICTV-Virus-Knowledgebase/MSL_merge)
1. Start a new load notebook by copying the previous one: [0.a.NOTEBOOK_ICTV_MSL37_2021.docx](0.a.NOTEBOOK_ICTV_MSL37_2021.docx)
1. rename current `load_next_msl` table to `load_next_msl_##`, where `##` is the number of the MSL loaded by that table. Use the script [0.b1. rename old load_next_msl.sql](0.b1. rename old load_next_msl.sql)
1. Create a new `load_next_msl` table using [0.b2.create_table-load_next_msl-delta.sql](0.b2.create_table-load_next_msl-delta.sql)
1. work through the various scripts in order, addressing QC problems
1. export a new MSL using [9za.EXPORT_MSL_extended_from_taxonomy_node.sql](9za.EXPORT_MSL_extended_from_taxonomy_node.sql)
1. copy dev db to production server



