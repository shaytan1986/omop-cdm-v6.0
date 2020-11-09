use master
go
if db_id('OMOP_v6') is null
begin
	create database OMOP_v6
	print 'Created database [OMOP_v6]'
end
go
use OMOP_v6
go


/************************
Standardized vocabulary
************************/
-- BEGIN: dbo.concept
drop table if exists dbo.concept
create table dbo.concept
(
    concept_id integer not null,
    concept_name varchar(4000) not null,
    domain_id varchar(20) not null,
    vocabulary_id varchar(20) not null,
    concept_class_id varchar(20) not null,
    standard_concept varchar(1) null,
    concept_code varchar(50) not null,
    valid_start_date date not null,
    valid_end_date date not null,
    invalid_reason varchar(1) null
);
-- END dbo.concept
-- BEGIN: dbo.vocabulary
drop table if exists dbo.vocabulary
create table dbo.vocabulary
(
    vocabulary_id varchar(20) not null,
    vocabulary_name varchar(255) not null,
    vocabulary_reference varchar(255) not null,
    vocabulary_version varchar(255) null,
    vocabulary_concept_id integer not null
);
-- END dbo.vocabulary
-- BEGIN: dbo.domain
drop table if exists dbo.domain
create table dbo.domain
(
    domain_id varchar(20) not null,
    domain_name varchar(255) not null,
    domain_concept_id integer not null
);
-- END dbo.domain
-- BEGIN: dbo.concept_class
drop table if exists dbo.concept_class
create table dbo.concept_class
(
    concept_class_id varchar(20) not null,
    concept_class_name varchar(4000) not null,
    concept_class_concept_id integer not null
);
-- END dbo.concept_class
-- BEGIN: dbo.concept_relationship
drop table if exists dbo.concept_relationship
create table dbo.concept_relationship
(
    concept_id_1 integer not null,
    concept_id_2 integer not null,
    relationship_id varchar(20) not null,
    valid_start_date date not null,
    valid_end_date date not null,
    invalid_reason varchar(1) null
);
-- END dbo.concept_relationship
-- BEGIN: dbo.relationship
drop table if exists dbo.relationship
create table dbo.relationship
(
    relationship_id varchar(20) not null,
    relationship_name varchar(255) not null,
    is_hierarchical varchar(1) not null,
    defines_ancestry varchar(1) not null,
    reverse_relationship_id varchar(20) not null,
    relationship_concept_id integer not null
);
-- END dbo.relationship
-- BEGIN: dbo.concept_synonym
drop table if exists dbo.concept_synonym
create table dbo.concept_synonym
(
    concept_id integer not null,
    concept_synonym_name varchar(4000) not null,
    language_concept_id integer not null
);
-- END dbo.concept_synonym
-- BEGIN: dbo.concept_ancestor
drop table if exists dbo.concept_ancestor
create table dbo.concept_ancestor
(
    ancestor_concept_id integer not null,
    descendant_concept_id integer not null,
    min_levels_of_separation integer not null,
    max_levels_of_separation integer not null
);
-- END dbo.concept_ancestor
-- BEGIN: dbo.source_to_concept_map
drop table if exists dbo.source_to_concept_map
create table dbo.source_to_concept_map
(
    source_code varchar(50) not null,
    source_concept_id integer not null,
    source_vocabulary_id varchar(20) not null,
    source_code_description varchar(255) null,
    target_concept_id integer not null,
    target_vocabulary_id varchar(20) not null,
    valid_start_date date not null,
    valid_end_date date not null,
    invalid_reason varchar(1) null
);
-- END dbo.source_to_concept_map
-- BEGIN: dbo.drug_strength
drop table if exists dbo.drug_strength
create table dbo.drug_strength
(
    drug_concept_id integer not null,
    ingredient_concept_id integer not null,
    amount_value float null,
    amount_unit_concept_id integer null,
    numerator_value float null,
    numerator_unit_concept_id integer null,
    denominator_value float null,
    denominator_unit_concept_id integer null,
    box_size integer null,
    valid_start_date date not null,
    valid_end_date date not null,
    invalid_reason varchar(1) null
);
-- END dbo.drug_strength
/**************************
Standardized meta-data
***************************/
-- BEGIN: dbo.cdm_source
drop table if exists dbo.cdm_source
create table dbo.cdm_source
(
    cdm_source_name varchar(255) not null,
    cdm_source_abbreviation varchar(25) null,
    cdm_holder varchar(255) null,
    source_description varchar(max) null,
    source_documentation_reference varchar(255) null,
    cdm_etl_reference varchar(255) null,
    source_release_date date null,
    cdm_release_date date null,
    cdm_version varchar(10) null,
    vocabulary_version varchar(20) null
);
-- END dbo.cdm_source
-- BEGIN: dbo.metadata
drop table if exists dbo.metadata
create table dbo.metadata
(
    metadata_concept_id integer not null,
    metadata_type_concept_id integer not null,
    name varchar(250) not null,
    value_as_string varchar(max) null,
    value_as_concept_id integer null,
    metadata_date date null,
    metadata_datetime datetime2 null
);
-- END dbo.metadata
insert into dbo.metadata
(
    metadata_concept_id,
    metadata_type_concept_id,
    name,
    value_as_string,
    value_as_concept_id,
    metadata_date,
    metadata_datetime
) --Added cdm version record
values
(
    0, 0, 'CDM Version', '6.0', 0, null, null
);
/************************
Standardized clinical data
************************/
-- BEGIN: dbo.person
drop table if exists dbo.person
create table dbo.person
(
    person_id bigint not null,
    gender_concept_id integer not null,
    year_of_birth integer not null,
    month_of_birth integer null,
    day_of_birth integer null,
    birth_datetime datetime2 null,
    death_datetime datetime2 null,
    race_concept_id integer not null,
    ethnicity_concept_id integer not null,
    location_id bigint null,
    provider_id bigint null,
    care_site_id bigint null,
    person_source_value varchar(50) null,
    gender_source_value varchar(50) null,
    gender_source_concept_id integer not null,
    race_source_value varchar(50) null,
    race_source_concept_id integer not null,
    ethnicity_source_value varchar(50) null,
    ethnicity_source_concept_id integer not null
);
-- END dbo.person
-- BEGIN: dbo.observation_period
drop table if exists dbo.observation_period
create table dbo.observation_period
(
    observation_period_id bigint not null,
    person_id bigint not null,
    observation_period_start_date date not null,
    observation_period_end_date date not null,
    period_type_concept_id integer not null
);
-- END dbo.observation_period
-- BEGIN: dbo.specimen
drop table if exists dbo.specimen
create table dbo.specimen
(
    specimen_id bigint not null,
    person_id bigint not null,
    specimen_concept_id integer not null,
    specimen_type_concept_id integer not null,
    specimen_date date null,
    specimen_datetime datetime2 not null,
    quantity float null,
    unit_concept_id integer null,
    anatomic_site_concept_id integer not null,
    disease_status_concept_id integer not null,
    specimen_source_id varchar(50) null,
    specimen_source_value varchar(50) null,
    unit_source_value varchar(50) null,
    anatomic_site_source_value varchar(50) null,
    disease_status_source_value varchar(50) null
);
-- END dbo.specimen
-- BEGIN: dbo.visit_occurrence
drop table if exists dbo.visit_occurrence
create table dbo.visit_occurrence
(
    visit_occurrence_id bigint not null,
    person_id bigint not null,
    visit_concept_id integer not null,
    visit_start_date date null,
    visit_start_datetime datetime2 not null,
    visit_end_date date null,
    visit_end_datetime datetime2 not null,
    visit_type_concept_id integer not null,
    provider_id bigint null,
    care_site_id bigint null,
    visit_source_value varchar(50) null,
    visit_source_concept_id integer not null,
    admitted_from_concept_id integer not null,
    admitted_from_source_value varchar(50) null,
    discharge_to_source_value varchar(50) null,
    discharge_to_concept_id integer not null,
    preceding_visit_occurrence_id bigint null
);
-- END dbo.visit_occurrence
-- BEGIN: dbo.visit_detail
drop table if exists dbo.visit_detail
create table dbo.visit_detail
(
    visit_detail_id bigint not null,
    person_id bigint not null,
    visit_detail_concept_id integer not null,
    visit_detail_start_date date null,
    visit_detail_start_datetime datetime2 not null,
    visit_detail_end_date date null,
    visit_detail_end_datetime datetime2 not null,
    visit_detail_type_concept_id integer not null,
    provider_id bigint null,
    care_site_id bigint null,
    discharge_to_concept_id integer not null,
    admitted_from_concept_id integer not null,
    admitted_from_source_value varchar(50) null,
    visit_detail_source_value varchar(50) null,
    visit_detail_source_concept_id integer not null,
    discharge_to_source_value varchar(50) null,
    preceding_visit_detail_id bigint null,
    visit_detail_parent_id bigint null,
    visit_occurrence_id bigint not null
);
-- END dbo.visit_detail
-- BEGIN: dbo.procedure_occurrence
drop table if exists dbo.procedure_occurrence
create table dbo.procedure_occurrence
(
    procedure_occurrence_id bigint not null,
    person_id bigint not null,
    procedure_concept_id integer not null,
    procedure_date date null,
    procedure_datetime datetime2 not null,
    procedure_type_concept_id integer not null,
    modifier_concept_id integer not null,
    quantity integer null,
    provider_id bigint null,
    visit_occurrence_id bigint null,
    visit_detail_id bigint null,
    procedure_source_value varchar(50) null,
    procedure_source_concept_id integer not null,
    modifier_source_value varchar(50) null
);
-- END dbo.procedure_occurrence
-- BEGIN: dbo.drug_exposure
drop table if exists dbo.drug_exposure
create table dbo.drug_exposure
(
    drug_exposure_id bigint not null,
    person_id bigint not null,
    drug_concept_id integer not null,
    drug_exposure_start_date date null,
    drug_exposure_start_datetime datetime2 not null,
    drug_exposure_end_date date null,
    drug_exposure_end_datetime datetime2 not null,
    verbatim_end_date date null,
    drug_type_concept_id integer not null,
    stop_reason varchar(20) null,
    refills integer null,
    quantity float null,
    days_supply integer null,
    sig varchar(max) null,
    route_concept_id integer not null,
    lot_number varchar(50) null,
    provider_id bigint null,
    visit_occurrence_id bigint null,
    visit_detail_id bigint null,
    drug_source_value varchar(50) null,
    drug_source_concept_id integer not null,
    route_source_value varchar(50) null,
    dose_unit_source_value varchar(50) null
);
-- END dbo.drug_exposure
-- BEGIN: dbo.device_exposure
drop table if exists dbo.device_exposure
create table dbo.device_exposure
(
    device_exposure_id bigint not null,
    person_id bigint not null,
    device_concept_id integer not null,
    device_exposure_start_date date null,
    device_exposure_start_datetime datetime2 not null,
    device_exposure_end_date date null,
    device_exposure_end_datetime datetime2 null,
    device_type_concept_id integer not null,
    unique_device_id varchar(50) null,
    quantity integer null,
    provider_id bigint null,
    visit_occurrence_id bigint null,
    visit_detail_id bigint null,
    device_source_value varchar(100) null,
    device_source_concept_id integer not null
);
-- END dbo.device_exposure
-- BEGIN: dbo.condition_occurrence
drop table if exists dbo.condition_occurrence
create table dbo.condition_occurrence
(
    condition_occurrence_id bigint not null,
    person_id bigint not null,
    condition_concept_id integer not null,
    condition_start_date date null,
    condition_start_datetime datetime2 not null,
    condition_end_date date null,
    condition_end_datetime datetime2 null,
    condition_type_concept_id integer not null,
    condition_status_concept_id integer not null,
    stop_reason varchar(20) null,
    provider_id bigint null,
    visit_occurrence_id bigint null,
    visit_detail_id bigint null,
    condition_source_value varchar(50) null,
    condition_source_concept_id integer not null,
    condition_status_source_value varchar(50) null
);
-- END dbo.condition_occurrence
-- BEGIN: dbo.measurement
drop table if exists dbo.measurement
create table dbo.measurement
(
    measurement_id bigint not null,
    person_id bigint not null,
    measurement_concept_id integer not null,
    measurement_date date null,
    measurement_datetime datetime2 not null,
    measurement_time varchar(10) null,
    measurement_type_concept_id integer not null,
    operator_concept_id integer null,
    value_as_number float null,
    value_as_concept_id integer null,
    unit_concept_id integer null,
    range_low float null,
    range_high float null,
    provider_id bigint null,
    visit_occurrence_id bigint null,
    visit_detail_id bigint null,
    measurement_source_value varchar(50) null,
    measurement_source_concept_id integer not null,
    unit_source_value varchar(50) null,
    value_source_value varchar(50) null
);
-- END dbo.measurement
-- BEGIN: dbo.note
drop table if exists dbo.note
create table dbo.note
(
    note_id bigint not null,
    person_id bigint not null,
    note_event_id bigint null,
    note_event_field_concept_id integer not null,
    note_date date null,
    note_datetime datetime2 not null,
    note_type_concept_id integer not null,
    note_class_concept_id integer not null,
    note_title varchar(250) null,
    note_text varchar(max) null,
    encoding_concept_id integer not null,
    language_concept_id integer not null,
    provider_id bigint null,
    visit_occurrence_id bigint null,
    visit_detail_id bigint null,
    note_source_value varchar(50) null
);
-- END dbo.note
-- BEGIN: dbo.note_nlp
drop table if exists dbo.note_nlp
create table dbo.note_nlp
(
    note_nlp_id bigint not null,
    note_id bigint not null,
    section_concept_id integer not null,
    snippet varchar(250) null,
    "offset" varchar(250) null,
    lexical_variant varchar(250) not null,
    note_nlp_concept_id integer not null,
    nlp_system varchar(250) null,
    nlp_date date not null,
    nlp_datetime datetime2 null,
    term_exists varchar(1) null,
    term_temporal varchar(50) null,
    term_modifiers varchar(2000) null,
    note_nlp_source_concept_id integer not null
);
-- END dbo.note_nlp
-- BEGIN: dbo.observation
drop table if exists dbo.observation
create table dbo.observation
(
    observation_id bigint not null,
    person_id bigint not null,
    observation_concept_id integer not null,
    observation_date date null,
    observation_datetime datetime2 not null,
    observation_type_concept_id integer not null,
    value_as_number float null,
    value_as_string varchar(60) null,
    value_as_concept_id integer null,
    qualifier_concept_id integer null,
    unit_concept_id integer null,
    provider_id integer null,
    visit_occurrence_id bigint null,
    visit_detail_id bigint null,
    observation_source_value varchar(50) null,
    observation_source_concept_id integer not null,
    unit_source_value varchar(50) null,
    qualifier_source_value varchar(50) null,
    observation_event_id bigint null,
    obs_event_field_concept_id integer not null,
    value_as_datetime datetime2 null
);
-- END dbo.observation
-- BEGIN: dbo.survey_conduct
drop table if exists dbo.survey_conduct
create table dbo.survey_conduct
(
    survey_conduct_id bigint not null,
    person_id bigint not null,
    survey_concept_id integer not null,
    survey_start_date date null,
    survey_start_datetime datetime2 null,
    survey_end_date date null,
    survey_end_datetime datetime2 not null,
    provider_id bigint null,
    assisted_concept_id integer not null,
    respondent_type_concept_id integer not null,
    timing_concept_id integer not null,
    collection_method_concept_id integer not null,
    assisted_source_value varchar(50) null,
    respondent_type_source_value varchar(100) null,
    timing_source_value varchar(100) null,
    collection_method_source_value varchar(100) null,
    survey_source_value varchar(100) null,
    survey_source_concept_id integer not null,
    survey_source_identifier varchar(100) null,
    validated_survey_concept_id integer not null,
    validated_survey_source_value varchar(100) null,
    survey_version_number varchar(20) null,
    visit_occurrence_id bigint null,
    visit_detail_id bigint null,
    response_visit_occurrence_id bigint null
);
-- END dbo.survey_conduct
-- BEGIN: dbo.fact_relationship
drop table if exists dbo.fact_relationship
create table dbo.fact_relationship
(
    domain_concept_id_1 integer not null,
    fact_id_1 bigint not null,
    domain_concept_id_2 integer not null,
    fact_id_2 bigint not null,
    relationship_concept_id integer not null
);
-- END dbo.fact_relationship
/************************
Standardized health system data
************************/
-- BEGIN: dbo.location
drop table if exists dbo.location
create table dbo.location
(
    location_id bigint not null,
    address_1 varchar(50) null,
    address_2 varchar(50) null,
    city varchar(50) null,
    state varchar(2) null,
    zip varchar(9) null,
    county varchar(20) null,
    country varchar(100) null,
    location_source_value varchar(50) null,
    latitude float null,
    longitude float null
);
-- END dbo.location
-- BEGIN: dbo.location_history
drop table if exists dbo.location_history
create table dbo.location_history
(
    location_history_id bigint not null,
    location_id bigint not null,
    relationship_type_concept_id integer not null,
    domain_id varchar(50) not null,
    entity_id bigint not null,
    start_date date not null,
    end_date date null
);
-- END dbo.location_history
-- BEGIN: dbo.care_site
drop table if exists dbo.care_site
create table dbo.care_site
(
    care_site_id bigint not null,
    care_site_name varchar(255) null,
    place_of_service_concept_id integer not null,
    location_id bigint null,
    care_site_source_value varchar(50) null,
    place_of_service_source_value varchar(50) null
);
-- END dbo.care_site
-- BEGIN: dbo.provider
drop table if exists dbo.provider
create table dbo.provider
(
    provider_id bigint not null,
    provider_name varchar(255) null,
    NPI varchar(20) null,
    DEA varchar(20) null,
    specialty_concept_id integer not null,
    care_site_id bigint null,
    year_of_birth integer null,
    gender_concept_id integer not null,
    provider_source_value varchar(50) null,
    specialty_source_value varchar(50) null,
    specialty_source_concept_id integer not null,
    gender_source_value varchar(50) null,
    gender_source_concept_id integer not null
);
-- END dbo.provider
/************************
Standardized health economics
************************/
-- BEGIN: dbo.payer_plan_period
drop table if exists dbo.payer_plan_period
create table dbo.payer_plan_period
(
    payer_plan_period_id bigint not null,
    person_id bigint not null,
    contract_person_id bigint null,
    payer_plan_period_start_date date not null,
    payer_plan_period_end_date date not null,
    payer_concept_id integer not null,
    plan_concept_id integer not null,
    contract_concept_id integer not null,
    sponsor_concept_id integer not null,
    stop_reason_concept_id integer not null,
    payer_source_value varchar(50) null,
    payer_source_concept_id integer not null,
    plan_source_value varchar(50) null,
    plan_source_concept_id integer not null,
    contract_source_value varchar(50) null,
    contract_source_concept_id integer not null,
    sponsor_source_value varchar(50) null,
    sponsor_source_concept_id integer not null,
    family_source_value varchar(50) null,
    stop_reason_source_value varchar(50) null,
    stop_reason_source_concept_id integer not null
);
-- END dbo.payer_plan_period
-- BEGIN: dbo.cost
drop table if exists dbo.cost
create table dbo.cost
(
    cost_id bigint not null,
    person_id bigint not null,
    cost_event_id bigint not null,
    cost_event_field_concept_id integer not null,
    cost_concept_id integer not null,
    cost_type_concept_id integer not null,
    currency_concept_id integer not null,
    cost float null,
    incurred_date date not null,
    billed_date date null,
    paid_date date null,
    revenue_code_concept_id integer not null,
    drg_concept_id integer not null,
    cost_source_value varchar(50) null,
    cost_source_concept_id integer not null,
    revenue_code_source_value varchar(50) null,
    drg_source_value varchar(3) null,
    payer_plan_period_id bigint null
);
-- END dbo.cost
/************************
Standardized derived elements
************************/
-- BEGIN: dbo.drug_era
drop table if exists dbo.drug_era
create table dbo.drug_era
(
    drug_era_id bigint not null,
    person_id bigint not null,
    drug_concept_id integer not null,
    drug_era_start_datetime datetime2 not null,
    drug_era_end_datetime datetime2 not null,
    drug_exposure_count integer null,
    gap_days integer null
);
-- END dbo.drug_era
-- BEGIN: dbo.dose_era
drop table if exists dbo.dose_era
create table dbo.dose_era
(
    dose_era_id bigint not null,
    person_id bigint not null,
    drug_concept_id integer not null,
    unit_concept_id integer not null,
    dose_value float not null,
    dose_era_start_datetime datetime2 not null,
    dose_era_end_datetime datetime2 not null
);
-- END dbo.dose_era
-- BEGIN: dbo.condition_era
drop table if exists dbo.condition_era
create table dbo.condition_era
(
    condition_era_id bigint not null,
    person_id bigint not null,
    condition_concept_id integer not null,
    condition_era_start_datetime datetime2 not null,
    condition_era_end_datetime datetime2 not null,
    condition_occurrence_count integer null
);
-- END dbo.condition_era
