declare @tabs table
(
	Name nvarchar(128),
	TwoPartName as concat('[dbo].', quotename(Name)),
	TabCol as concat('__TAB = ', quotename('[dbo].' + quotename(Name), ''''))
)

insert into @tabs (Name)
values
	('concept'),
	('vocabulary'),
	('domain'),
	('concept_class'),
	('concept_relationship'),
	('relationship'),
	('concept_synonym'),
	('concept_ancestor'),
	('source_to_concept_map'),
	('drug_strength')

select
	a.TwoPartName,
	SelectTop1000 = concat('select top 100 ', a.TabCol, ', * from ', a.twoPartName, ' with (nolock)'),
	SelectCt = concat('select ', a.TabCol, ', Ct = count(1) from ', a.twoPartName, ' with (nolock)')
from @tabs a
inner join sys.tables b
	on object_id(a.TwoPartName) = b.object_id

/*
select top 100 __TAB = 'dbo.concept', * from dbo.concept with (nolock)
select top 100 __TAB = 'dbo.vocabulary', * from dbo.vocabulary with (nolock)
select top 100 __TAB = 'dbo.domain', * from dbo.domain with (nolock)
select top 100 __TAB = 'dbo.concept_class', * from dbo.concept_class with (nolock)
select top 100 __TAB = 'dbo.concept_relationship', * from dbo.concept_relationship with (nolock)
select top 100 __TAB = 'dbo.relationship', * from dbo.relationship with (nolock)
select top 100 __TAB = 'dbo.concept_synonym', * from dbo.concept_synonym with (nolock)
select top 100 __TAB = 'dbo.concept_ancestor', * from dbo.concept_ancestor with (nolock)
select top 100 __TAB = 'dbo.source_to_concept_map', * from dbo.source_to_concept_map with (nolock)
select top 100 __TAB = 'dbo.drug_strength', * from dbo.drug_strength with (nolock)
*/
select
	a.TwoPartName,
	RowCt = max(b.rows)
from @tabs a
inner join sys.partitions b
	on object_id(a.TwoPartName) = b.object_id
group by a.TwoPartName


select
    a.concept_id,
    a.concept_name,
    a.domain_id,
    a.vocabulary_id,
    a.concept_class_id,
    a.standard_concept,
    a.concept_code,
	b.relationship_id,
	c.concept_id,
    c.concept_name,
    c.domain_id,
    c.vocabulary_id,
    c.concept_class_id,
    c.standard_concept,
    c.concept_code
from OMOP_v6.dbo.concept a
inner join OMOP_v6.dbo.concept_relationship b
	on a.concept_id = b.concept_id_1
inner join OMOP_v6.dbo.concept c
	on b.concept_id_2 = c.concept_id
where a.domain_id = 'metadata'
    and a.vocabulary_id in
        (
            'Relationship',
            'Vocabulary',
            'CDM',
            'read',
            'Metadata',
            'domain'
        )
    and a.concept_name like '%source[_]value%'
order by a.vocabulary_id