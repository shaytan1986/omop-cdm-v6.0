param(
    [string]$vocabDir="G:\data\omop\vocab\2020-11-06 ALL",
    [switch]$refresh
)
$DATA_DIR=$vocabDir
$SQL_INSTANCE="localhost\lemur"
$DB="OMOP_v6"

function getTableName() {
    param(
        [string]$name
    )

    if ($name -eq "CONCEPT_CPT4") {
        $tab="dbo.CONCEPT"
    } else {
        $tab="dbo.${name}"
    }
    return $tab
}
function getRows() {
    param(
        [string]$name
    )
    $tab = getTableName $baseName
    $rs = Invoke-Sqlcmd -ServerInstance "$SQL_INSTANCE" -Database "$DB" -Query "select RowCt = max(rows) from sys.partitions where object_id = object_id('${tab}')"
    return $rs.RowCt
}


function bulkInsertSql() {
    param(
        [string]$name
    )

    $tab = getTableName $name
    $extless="${DATA_DIR}\${name}"
    return "
TRUNCATE TABLE ${tab};
BULK INSERT ${tab}
FROM '${extless}.csv' 
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = '\t',
ROWTERMINATOR = '0x0a',
TABLOCK
);
select RowCt = max(rows) from sys.partitions where object_id = object_id('${tab}')
"
}

function setMetadata() {
    $query="delete from OMOP_v6.dbo.metadata where name = 'CDM Version'
    insert into OMOP_v6.dbo.metadata
    (
        metadata_concept_id,
        metadata_type_concept_id,
        name,
        value_as_string,
        value_as_concept_id,
        metadata_date,
        metadata_datetime
    )
    select 
        metadata_concept_id = concept_id,
        metadata_type_concept_id = 0,
        name = 'CDM Version',
        value_as_string = concept_code,
        value_as_concept_id = 1147652,
        metadata_date = sysutcdatetime(),
        metadata_datetime = sysutcdatetime()
    from OMOP_v6.dbo.concept
    where domain_id = 'Metadata'
        and vocabulary_id = 'CDM'
        and concept_class_id = 'CDM'
        and concept_code = 'CDM v6.0.0'"
    Invoke-Sqlcmd -ServerInstance "$SQL_INSTANCE" -Database "$DB" -Query "$query"
    Write-Host ""
}

Get-ChildItem -Path $DATA_DIR -Filter *.csv | ForEach-Object {
    $baseName=$_.BaseName
    $query = bulkInsertSql $baseName    
    $rows = getRows $baseName

    if (($refresh) -or ($rows -eq 0)) {
        Write-Host "Loading $baseName..."
        $rc = (Invoke-Sqlcmd -ServerInstance "$SQL_INSTANCE" -Database "$DB" -Query "$query").RowCt
        Write-Host "  ...Done ($rc rows)"
    } else {
        Write-Host "Skipping $baseName. RowCt: $rows"
    }
}

