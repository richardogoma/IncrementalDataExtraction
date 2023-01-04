#! pwsh.exe
# Full batch data pipeline
Param(
    [Parameter(Mandatory)]
    [ValidateSet("MD5", "SHA1", "SHA256", "SHA384", "SHA512")]
    [string]
    $algorithm, 

    [Parameter(Mandatory)]
    [string]
    $cwd
)
Set-Variable -Name "apiEndpoint" -Value "https://api.coindesk.com/v1/bpi/currentprice.json"
Set-Variable -Name "localFileName" -Value "BitcoinPriceIndex"
# ---------------------------------------------
# Start job to calculate hash value and return API endpoint resource
$apiJob = Start-Job -ScriptBlock { param($apiEndpoint, $algorithm, $cwd)
    & "$cwd\Calculate-DataHash.ps1" -DataSource $apiEndpoint -Algorithm $algorithm -Mode Compare
    } -ArgumentList $apiEndpoint, $algorithm, $cwd

# Wait for the job to complete
Wait-Job -Job $apiJob

# Get the results of the job
$apiDataArray = Receive-Job -Job $apiJob

# Remove the job from the session
Remove-Job -Job $apiJob
if ( $apiDataArray.Count -eq 2 ) {
    # Piping job response to file I/O
    Write-Host "Creating CSV and JSON hash files ..." -ForegroundColor Green
    $apiDataArray[0] | ConvertTo-Json | Out-File ("{0}\{1}Hash.json" -f $cwd, $localFileName)

    $headers = $apiDataArray[1] | Get-member -MemberType 'NoteProperty' -Name chartName,EUR,GBP,USD,updatedtimeISO |`
             Select-Object -ExpandProperty 'Name'
    $headers | ConvertTo-Json | Out-File ("{0}\{1}.json" -f $cwd, "docschema")

    $apiDataArray[1] | Select-Object -Property ($headers -join ",").Split(",") | Export-Csv -Path "$cwd\$localFileName.csv" -NoTypeInformation
    Write-Host "Bitcoin price index data created with rows: "($apiDataArray[1]).Count -ForegroundColor Green
} else {
    Write-Host $apiDataArray -ForegroundColor Red
    Write-Host "Fatal Failure... Full batch data extraction failed!" -ForegroundColor Red
    Exit 
}