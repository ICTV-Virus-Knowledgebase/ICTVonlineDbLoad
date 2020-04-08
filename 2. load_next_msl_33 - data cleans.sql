-- data cleaning

-- remove leading and trailing spaces (update create in excel)
update load_next_msl_33 set
--select [change],[accessions],
      [proposal]=rtrim(ltrim(replace(replace([proposal],char(9),' '),'  ',' ')))
      ,[srcHigherTaxon]=rtrim(ltrim(replace(replace([srcHigherTaxon],char(9),' '),'  ',' ')))
      ,[srcOrder]=rtrim(ltrim(replace(replace([srcOrder],char(9),' '),'  ',' ')))
      ,[srcFamily]=rtrim(ltrim(replace(replace([srcFamily],char(9),' '),'  ',' ')))
      ,[srcSubfamily]=rtrim(ltrim(replace(replace([srcSubfamily],char(9),' '),'  ',' ')))
      ,[srcGenus]=rtrim(ltrim(replace(replace([srcGenus],char(9),' '),'  ',' ')))
      ,[srcSpecies]=rtrim(ltrim(replace(replace([srcSpecies],char(9),' '),'  ',' ')))
      ,[srcIsType]=rtrim(ltrim(replace(replace([srcIsType],char(9),' '),'  ',' ')))
      ,[srcAccessions]=rtrim(ltrim(replace(replace([srcAccessions],char(9),' '),'  ',' ')))
      ,[realm]=rtrim(ltrim(replace(replace([realm],char(9),' '),'  ',' ')))
      ,[subrealm]=rtrim(ltrim(replace(replace([subrealm],char(9),' '),'  ',' ')))
      ,[kingdom]=rtrim(ltrim(replace(replace([kingdom],char(9),' '),'  ',' ')))
      ,[subkingdom]=rtrim(ltrim(replace(replace([subkingdom],char(9),' '),'  ',' ')))
      ,[phylum]=rtrim(ltrim(replace(replace([phylum],char(9),' '),'  ',' ')))
      ,[subphylum]=rtrim(ltrim(replace(replace([subphylum],char(9),' '),'  ',' ')))
      ,[class]=rtrim(ltrim(replace(replace([class],char(9),' '),'  ',' ')))
      ,[subclass]=rtrim(ltrim(replace(replace([subclass],char(9),' '),'  ',' ')))
      ,[order]=rtrim(ltrim(replace(replace([order],char(9),' '),'  ',' ')))
      ,[suborder]=rtrim(ltrim(replace(replace([suborder],char(9),' '),'  ',' ')))
      ,[family]=rtrim(ltrim(replace(replace([family],char(9),' '),'  ',' ')))
      ,[subfamily]=rtrim(ltrim(replace(replace([subfamily],char(9),' '),'  ',' ')))
      ,[genus]=rtrim(ltrim(replace(replace([genus],char(9),' '),'  ',' ')))
      ,[subgenus]=rtrim(ltrim(replace(replace([subgenus],char(9),' '),'  ',' ')))
      ,[species]=rtrim(ltrim(replace(replace([species],char(9),' '),'  ',' ')))
      ,[isType]=rtrim(ltrim(replace(replace([isType],char(9),' '),'  ',' ')))
      ,[accessions]=rtrim(ltrim(replace(replace([accessions],char(9),' '),'  ',' ')))
      ,[exemplarName]=rtrim(ltrim(replace(replace([exemplarName],char(9),' '),'  ',' ')))
      ,[exemplarID]=rtrim(ltrim(replace(replace([exemplarID],char(9),' '),'  ',' ')))
      ,[isComplete]=rtrim(ltrim(replace(replace([isComplete],char(9),' '),'  ',' ')))
      ,[Abbrev]=rtrim(ltrim(replace(replace([Abbrev],char(9),' '),'  ',' ')))
      ,[change]=rtrim(ltrim(replace(replace([change],char(9),' '),'  ',' ')))
from load_next_msl_33
where
([proposal] is not null and ([proposal] like ' %' or [proposal] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([srcHigherTaxon] is not null and ([srcHigherTaxon] like ' %' or [srcHigherTaxon] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([srcOrder] is not null and ([srcOrder] like ' %' or [srcOrder] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([srcFamily] is not null and ([srcFamily] like ' %' or [srcFamily] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([srcSubfamily] is not null and ([srcSubfamily] like ' %' or [srcSubfamily] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([srcGenus] is not null and ([srcGenus] like ' %' or [srcGenus] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([srcSpecies] is not null and ([srcSpecies] like ' %' or [srcSpecies] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([srcIsType] is not null and ([srcIsType] like ' %' or [srcIsType] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([srcAccessions] is not null and ([srcAccessions] like ' %' or [srcAccessions] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([realm] is not null and ([realm] like ' %' or [realm] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([subrealm] is not null and ([subrealm] like ' %' or [subrealm] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([kingdom] is not null and ([kingdom] like ' %' or [kingdom] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([subkingdom] is not null and ([subkingdom] like ' %' or [subkingdom] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([phylum] is not null and ([phylum] like ' %' or [phylum] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([subphylum] is not null and ([subphylum] like ' %' or [subphylum] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([class] is not null and ([class] like ' %' or [class] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([subclass] is not null and ([subclass] like ' %' or [subclass] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([order] is not null and ([order] like ' %' or [order] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([suborder] is not null and ([suborder] like ' %' or [suborder] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([family] is not null and ([family] like ' %' or [family] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([subfamily] is not null and ([subfamily] like ' %' or [subfamily] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([genus] is not null and ([genus] like ' %' or [genus] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([subgenus] is not null and ([subgenus] like ' %' or [subgenus] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([species] is not null and ([species] like ' %' or [species] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([isType] is not null and ([isType] like ' %' or [isType] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([accessions] is not null and ([accessions] like ' %' or [accessions] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([exemplarName] is not null and ([exemplarName] like ' %' or [exemplarName] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([exemplarID] is not null and ([exemplarID] like ' %' or [exemplarID] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([isComplete] is not null and ([isComplete] like ' %' or [isComplete] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([Abbrev] is not null and ([Abbrev] like ' %' or [Abbrev] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %')) or  
([change] is not null and ([change] like ' %' or [change] like '% ' or [change] like '%'+char(9)+'%' or [change] like '%  %'))   

-- map word smart quotes to regular quotes

print 'open smart quote ('+char(147)+') = '+rtrim(ascii('“'))
print 'close smart quote ('+char(148)+') = '+rtrim(ascii('”'))
print 'ASCII quote ('+char(34)+') = '+rtrim(ascii('"'))


update load_next_msl_33 set
--select 
      [proposal]=replace(replace([proposal],char(147),char(34)),char(148),char(34))
      ,[srcHigherTaxon]=replace(replace([srcHigherTaxon],char(147),char(34)),char(148),char(34))
      ,[srcOrder]=replace(replace([srcOrder],char(147),char(34)),char(148),char(34))
      ,[srcFamily]=replace(replace([srcFamily],char(147),char(34)),char(148),char(34))
      ,[srcSubfamily]=replace(replace([srcSubfamily],char(147),char(34)),char(148),char(34))
      ,[srcGenus]=replace(replace([srcGenus],char(147),char(34)),char(148),char(34))
      ,[srcSpecies]=replace(replace([srcSpecies],char(147),char(34)),char(148),char(34))
      ,[srcIsType]=replace(replace([srcIsType],char(147),char(34)),char(148),char(34))
      ,[srcAccessions]=replace(replace([srcAccessions],char(147),char(34)),char(148),char(34))
      ,[realm]=replace(replace([realm],char(147),char(34)),char(148),char(34))
      ,[subrealm]=replace(replace([subrealm],char(147),char(34)),char(148),char(34))
      ,[kingdom]=replace(replace([kingdom],char(147),char(34)),char(148),char(34))
      ,[subkingdom]=replace(replace([subkingdom],char(147),char(34)),char(148),char(34))
      ,[phylum]=replace(replace([phylum],char(147),char(34)),char(148),char(34))
      ,[subphylum]=replace(replace([subphylum],char(147),char(34)),char(148),char(34))
      ,[class]=replace(replace([class],char(147),char(34)),char(148),char(34))
      ,[subclass]=replace(replace([subclass],char(147),char(34)),char(148),char(34))
      ,[order]=replace(replace([order],char(147),char(34)),char(148),char(34))
      ,[suborder]=replace(replace([suborder],char(147),char(34)),char(148),char(34))
      ,[family]=replace(replace([family],char(147),char(34)),char(148),char(34))
      ,[subfamily]=replace(replace([subfamily],char(147),char(34)),char(148),char(34))
      ,[genus]=replace(replace([genus],char(147),char(34)),char(148),char(34))
      ,[subgenus]=replace(replace([subgenus],char(147),char(34)),char(148),char(34))
      ,[species]=replace(replace([species],char(147),char(34)),char(148),char(34))
      ,[isType]=replace(replace([isType],char(147),char(34)),char(148),char(34))
      ,[accessions]=replace(replace([accessions],char(147),char(34)),char(148),char(34))
      ,[exemplarName]=replace(replace([exemplarName],char(147),char(34)),char(148),char(34))
      ,[exemplarID]=replace(replace([exemplarID],char(147),char(34)),char(148),char(34))
      ,[isComplete]=replace(replace([isComplete],char(147),char(34)),char(148),char(34))
      ,[Abbrev]=replace(replace([Abbrev],char(147),char(34)),char(148),char(34))
      ,[change]=replace(replace([change],char(147),char(34)),char(148),char(34))
from load_next_msl_33
where
([proposal] is not null and ([proposal] like '%'+char(147)+'%' or [proposal] like '%'+char(148)+'%')) or  -- word smart quotes
([srcHigherTaxon] is not null and ([srcHigherTaxon] like '%'+char(147)+'%' or [srcHigherTaxon] like '%'+char(148)+'%')) or  -- word smart quotes
([srcOrder] is not null and ([srcOrder] like '%'+char(147)+'%' or [srcOrder] like '%'+char(148)+'%')) or  -- word smart quotes
([srcFamily] is not null and ([srcFamily] like '%'+char(147)+'%' or [srcFamily] like '%'+char(148)+'%')) or  -- word smart quotes
([srcSubfamily] is not null and ([srcSubfamily] like '%'+char(147)+'%' or [srcSubfamily] like '%'+char(148)+'%')) or  -- word smart quotes
([srcGenus] is not null and ([srcGenus] like '%'+char(147)+'%' or [srcGenus] like '%'+char(148)+'%')) or  -- word smart quotes
([srcSpecies] is not null and ([srcSpecies] like '%'+char(147)+'%' or [srcSpecies] like '%'+char(148)+'%')) or  -- word smart quotes
([srcIsType] is not null and ([srcIsType] like '%'+char(147)+'%' or [srcIsType] like '%'+char(148)+'%')) or  -- word smart quotes
([srcAccessions] is not null and ([srcAccessions] like '%'+char(147)+'%' or [srcAccessions] like '%'+char(148)+'%')) or  -- word smart quotes
([realm] is not null and ([realm] like '%'+char(147)+'%' or [realm] like '%'+char(148)+'%')) or  -- word smart quotes
([subrealm] is not null and ([subrealm] like '%'+char(147)+'%' or [subrealm] like '%'+char(148)+'%')) or  -- word smart quotes
([kingdom] is not null and ([kingdom] like '%'+char(147)+'%' or [kingdom] like '%'+char(148)+'%')) or  -- word smart quotes
([subkingdom] is not null and ([subkingdom] like '%'+char(147)+'%' or [subkingdom] like '%'+char(148)+'%')) or  -- word smart quotes
([phylum] is not null and ([phylum] like '%'+char(147)+'%' or [phylum] like '%'+char(148)+'%')) or  -- word smart quotes
([subphylum] is not null and ([subphylum] like '%'+char(147)+'%' or [subphylum] like '%'+char(148)+'%')) or  -- word smart quotes
([class] is not null and ([class] like '%'+char(147)+'%' or [class] like '%'+char(148)+'%')) or  -- word smart quotes
([subclass] is not null and ([subclass] like '%'+char(147)+'%' or [subclass] like '%'+char(148)+'%')) or  -- word smart quotes
([order] is not null and ([order] like '%'+char(147)+'%' or [order] like '%'+char(148)+'%')) or  -- word smart quotes
([suborder] is not null and ([suborder] like '%'+char(147)+'%' or [suborder] like '%'+char(148)+'%')) or  -- word smart quotes
([family] is not null and ([family] like '%'+char(147)+'%' or [family] like '%'+char(148)+'%')) or  -- word smart quotes
([subfamily] is not null and ([subfamily] like '%'+char(147)+'%' or [subfamily] like '%'+char(148)+'%')) or  -- word smart quotes
([genus] is not null and ([genus] like '%'+char(147)+'%' or [genus] like '%'+char(148)+'%')) or  -- word smart quotes
([subgenus] is not null and ([subgenus] like '%'+char(147)+'%' or [subgenus] like '%'+char(148)+'%')) or  -- word smart quotes
([species] is not null and ([species] like '%'+char(147)+'%' or [species] like '%'+char(148)+'%')) or  -- word smart quotes
([isType] is not null and ([isType] like '%'+char(147)+'%' or [isType] like '%'+char(148)+'%')) or  -- word smart quotes
([accessions] is not null and ([accessions] like '%'+char(147)+'%' or [accessions] like '%'+char(148)+'%')) or  -- word smart quotes
([exemplarName] is not null and ([exemplarName] like '%'+char(147)+'%' or [exemplarName] like '%'+char(148)+'%')) or  -- word smart quotes
([exemplarID] is not null and ([exemplarID] like '%'+char(147)+'%' or [exemplarID] like '%'+char(148)+'%')) or  -- word smart quotes
([isComplete] is not null and ([isComplete] like '%'+char(147)+'%' or [isComplete] like '%'+char(148)+'%')) or  -- word smart quotes
([Abbrev] is not null and ([Abbrev] like '%'+char(147)+'%' or [Abbrev] like '%'+char(148)+'%')) or  -- word smart quotes
([change] is not null and ([change] like '%'+char(147)+'%' or [change] like '%'+char(148)+'%'))   -- word smart quotes


-- remove quotes around values
update load_next_msl_33 set 
-- select change,[srcAccessions],[accessions],
      [proposal]=(case when [proposal] like char(34)+'%'+char(34) then substring([proposal], 2, len([proposal])-2) else [proposal] end)
      ,[srcHigherTaxon]=(case when [srcHigherTaxon] like char(34)+'%'+char(34) then substring([srcHigherTaxon], 2, len([srcHigherTaxon])-2) else [srcHigherTaxon] end)
      ,[srcOrder]=(case when [srcOrder] like char(34)+'%'+char(34) then substring([srcOrder], 2, len([srcOrder])-2) else [srcOrder] end)
      ,[srcFamily]=(case when [srcFamily] like char(34)+'%'+char(34) then substring([srcFamily], 2, len([srcFamily])-2) else [srcFamily] end)
      ,[srcSubfamily]=(case when [srcSubfamily] like char(34)+'%'+char(34) then substring([srcSubfamily], 2, len([srcSubfamily])-2) else [srcSubfamily] end)
      ,[srcGenus]=(case when [srcGenus] like char(34)+'%'+char(34) then substring([srcGenus], 2, len([srcGenus])-2) else [srcGenus] end)
      ,[srcSpecies]=(case when [srcSpecies] like char(34)+'%'+char(34) then substring([srcSpecies], 2, len([srcSpecies])-2) else [srcSpecies] end)
      ,[srcIsType]=(case when [srcIsType] like char(34)+'%'+char(34) then substring([srcIsType], 2, len([srcIsType])-2) else [srcIsType] end)
      ,[srcAccessions]=(case when [srcAccessions] like char(34)+'%'+char(34) then substring([srcAccessions], 2, len([srcAccessions])-2) else [srcAccessions] end)
      ,[realm]=(case when [realm] like char(34)+'%'+char(34) then substring([realm], 2, len([realm])-2) else [realm] end)
      ,[subrealm]=(case when [subrealm] like char(34)+'%'+char(34) then substring([subrealm], 2, len([subrealm])-2) else [subrealm] end)
      ,[kingdom]=(case when [kingdom] like char(34)+'%'+char(34) then substring([kingdom], 2, len([kingdom])-2) else [kingdom] end)
      ,[subkingdom]=(case when [subkingdom] like char(34)+'%'+char(34) then substring([subkingdom], 2, len([subkingdom])-2) else [subkingdom] end)
      ,[phylum]=(case when [phylum] like char(34)+'%'+char(34) then substring([phylum], 2, len([phylum])-2) else [phylum] end)
      ,[subphylum]=(case when [subphylum] like char(34)+'%'+char(34) then substring([subphylum], 2, len([subphylum])-2) else [subphylum] end)
      ,[class]=(case when [class] like char(34)+'%'+char(34) then substring([class], 2, len([class])-2) else [class] end)
      ,[subclass]=(case when [subclass] like char(34)+'%'+char(34) then substring([subclass], 2, len([subclass])-2) else [subclass] end)
      ,[order]=(case when [order] like char(34)+'%'+char(34) then substring([order], 2, len([order])-2) else [order] end)
      ,[suborder]=(case when [suborder] like char(34)+'%'+char(34) then substring([suborder], 2, len([suborder])-2) else [suborder] end)
      ,[family]=(case when [family] like char(34)+'%'+char(34) then substring([family], 2, len([family])-2) else [family] end)
      ,[subfamily]=(case when [subfamily] like char(34)+'%'+char(34) then substring([subfamily], 2, len([subfamily])-2) else [subfamily] end)
      ,[genus]=(case when [genus] like char(34)+'%'+char(34) then substring([genus], 2, len([genus])-2) else [genus] end)
      ,[subgenus]=(case when [subgenus] like char(34)+'%'+char(34) then substring([subgenus], 2, len([subgenus])-2) else [subgenus] end)
      ,[species]=(case when [species] like char(34)+'%'+char(34) then substring([species], 2, len([species])-2) else [species] end)
      ,[isType]=(case when [isType] like char(34)+'%'+char(34) then substring([isType], 2, len([isType])-2) else [isType] end)
      ,[accessions]=(case when [accessions] like char(34)+'%'+char(34) then substring([accessions], 2, len([accessions])-2) else [accessions] end)
      ,[exemplarName]=(case when [exemplarName] like char(34)+'%'+char(34) then substring([exemplarName], 2, len([exemplarName])-2) else [exemplarName] end)
      ,[exemplarID]=(case when [exemplarID] like char(34)+'%'+char(34) then substring([exemplarID], 2, len([exemplarID])-2) else [exemplarID] end)
      ,[isComplete]=(case when [isComplete] like char(34)+'%'+char(34) then substring([isComplete], 2, len([isComplete])-2) else [isComplete] end)
      ,[Abbrev]=(case when [Abbrev] like char(34)+'%'+char(34) then substring([Abbrev], 2, len([Abbrev])-2) else [Abbrev] end)
      ,[change]=(case when [change] like char(34)+'%'+char(34) then substring([change], 2, len([change])-2) else [change] end)
from  load_next_msl_33
where  
([proposal] is not null and ([proposal] like char(34)+'%'+char(34))) or  -- double quotes
([srcHigherTaxon] is not null and ([srcHigherTaxon] like char(34)+'%'+char(34))) or  -- double quotes
([srcOrder] is not null and ([srcOrder] like char(34)+'%'+char(34))) or  -- double quotes
([srcFamily] is not null and ([srcFamily] like char(34)+'%'+char(34))) or  -- double quotes
([srcSubfamily] is not null and ([srcSubfamily] like char(34)+'%'+char(34))) or  -- double quotes
([srcGenus] is not null and ([srcGenus] like char(34)+'%'+char(34))) or  -- double quotes
([srcSpecies] is not null and ([srcSpecies] like char(34)+'%'+char(34))) or  -- double quotes
([srcIsType] is not null and ([srcIsType] like char(34)+'%'+char(34))) or  -- double quotes
([srcAccessions] is not null and ([srcAccessions] like char(34)+'%'+char(34))) or  -- double quotes
([realm] is not null and ([realm] like char(34)+'%'+char(34))) or  -- double quotes
([subrealm] is not null and ([subrealm] like char(34)+'%'+char(34))) or  -- double quotes
([kingdom] is not null and ([kingdom] like char(34)+'%'+char(34))) or  -- double quotes
([subkingdom] is not null and ([subkingdom] like char(34)+'%'+char(34))) or  -- double quotes
([phylum] is not null and ([phylum] like char(34)+'%'+char(34))) or  -- double quotes
([subphylum] is not null and ([subphylum] like char(34)+'%'+char(34))) or  -- double quotes
([class] is not null and ([class] like char(34)+'%'+char(34))) or  -- double quotes
([subclass] is not null and ([subclass] like char(34)+'%'+char(34))) or  -- double quotes
([order] is not null and ([order] like char(34)+'%'+char(34))) or  -- double quotes
([suborder] is not null and ([suborder] like char(34)+'%'+char(34))) or  -- double quotes
([family] is not null and ([family] like char(34)+'%'+char(34))) or  -- double quotes
([subfamily] is not null and ([subfamily] like char(34)+'%'+char(34))) or  -- double quotes
([genus] is not null and ([genus] like char(34)+'%'+char(34))) or  -- double quotes
([subgenus] is not null and ([subgenus] like char(34)+'%'+char(34))) or  -- double quotes
([species] is not null and ([species] like char(34)+'%'+char(34))) or  -- double quotes
([isType] is not null and ([isType] like char(34)+'%'+char(34))) or  -- double quotes
([accessions] is not null and ([accessions] like char(34)+'%'+char(34))) or  -- double quotes
([exemplarName] is not null and ([exemplarName] like char(34)+'%'+char(34))) or  -- double quotes
([exemplarID] is not null and ([exemplarID] like char(34)+'%'+char(34))) or  -- double quotes
([isComplete] is not null and ([isComplete] like char(34)+'%'+char(34))) or  -- double quotes
([Abbrev] is not null and ([Abbrev] like char(34)+'%'+char(34))) or  -- double quotes
([change] is not null and ([change] like char(34)+'%'+char(34)))   -- double quotes

-- DeBrazza's
-- possessive was removed from name in MSL32 (2017.001G.A.v2.43spren.zip)
update load_next_msl_33 set srcSpecies='DeBrazza monkey arterivirus' where srcSpecies like 'DeBrazza’s monkey arterivirus'

-- Alphamesonivirus 6/7
-- 2017.012_015S.A.v1.Nidovirales
update load_next_msl_33 set change ='new species' from load_next_msl_33 where species in ('Alphamesonivirus 6', 'Alphamesonivirus 7') and change like 'assign species to subgenus%'


print ascii('"')
-- null proposals are bad
select ERROR='NULL proposal field', *
from load_next_msl_33
where proposal is NULL

-- get correct suffixes on proposal names
update load_next_msl_33 set 
-- select count(*), proposal , 
	proposal=proposal+'.zip'
from load_next_msl_33 
where  proposal not like '%.___' and proposal not like '%.___x'
--group by proposal  -- for select summary

update load_next_msl_33 set 
-- select count(*), proposal , 
	proposal=left(proposal, len(proposal)-4)
from load_next_msl_33 
where  proposal  like '%.___.zip' or proposal  like '%.___x.zip'
--group by proposal  -- for select summary