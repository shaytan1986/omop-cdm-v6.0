$SCRIPTS_DIR="."
$DL_DIR="..\downloads"
$MANIFEST_PATH="${SCRIPTS_DIR}\manifest.json"

function dlFileName() {
    param(
        [string]$name
    )
    return "${DL_DIR}\$($_.name).sql"
}
$i=0

$js = Get-Content $MANIFEST_PATH | ConvertFrom-Json
$js.ohdsi.mssql | ForEach-Object {
    
    $uri = $_.uri
    $outFile = dlFileName $_.name
    Write-Host "[$i] Downloading $outFile"
    Invoke-WebRequest -Uri $uri -OutFile $outFile
    $i = $i + 1
    
}