-- convert blanks to NULLs
-- !! this is necessary when loading from .txt files, but not when loading from .xls !!
update load_next_msl set [sort]=null where [sort]=''

update load_next_msl set [proposal_abbrev]=null where [proposal_abbrev]=''


update load_next_msl set srcHigherTaxon=null where srcHigherTaxon=''
update load_next_msl set srcOrder=null where srcOrder=''
update load_next_msl set srcFamily=null where srcFamily=''
update load_next_msl set srcSubfamily=null where srcSubfamily=''
update load_next_msl set srcGenus=null where srcGenus=''
update load_next_msl set srcSpecies=null where srcSpecies=''
update load_next_msl set srcistype=null where srcistype=''

update load_next_msl set srcAccessions=null where srcAccessions=''
update load_next_msl set subphylum=null where subphylum=''
update load_next_msl set [class]=null where [class]=''

update load_next_msl set subclass=null where subclass=''
update load_next_msl set [order]=null where [order]=''
update load_next_msl set suborder=null where suborder=''
update load_next_msl set family=null where family=''
update load_next_msl set subfamily=null where subfamily=''
update load_next_msl set genus=null where genus=''
update load_next_msl set subgenus=null where subgenus=''
update load_next_msl set species=null where species=''
update load_next_msl set isType=null where isType=''

update load_next_msl set [exemplarAccessions]=null where [exemplarAccessions]=''
update load_next_msl set [exemplarRefSeq]=null where [exemplarRefSeq]=''
update load_next_msl set exemplarName=null where exemplarName=''
update load_next_msl set [exemplarIsolate]=null where [exemplarIsolate]=''
update load_next_msl set isComplete=null where isComplete=''
update load_next_msl set Abbrev=null where Abbrev=''
update load_next_msl set change=null where change=''
update load_next_msl set [rank]=null where [rank]=''