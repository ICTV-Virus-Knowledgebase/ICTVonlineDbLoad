# ICTVonlineDbLoad

Data and Schema from the website of the International Committee on the Taxonomy of Viruses (ICTV)
	* https://ICTV.global 

This database contains the current official taxonomy, down to the rank of species, as well as all the historical taxonomy from previous years. The taxa are linked across years (technically, Master Species List (MSL) releases), changes are linked to the supporting official documents that describe the rationales behind the changes. 

## Schema

Create scripts for the current MSSQL schema are found in [./schema/](schema/)

See schema documentation: [./schema/README.md](schema/README.md)

## Data dump

A dump of the core tables to TSV (tab seprated text file) can be found in [./data/](data/)

## NCBI Linkout

Latest NCBI Linkout feature file ncbi_linkout.ft, and supporting scripts can be found in [./ncbi_linkout](ncbi_linkout/)(


