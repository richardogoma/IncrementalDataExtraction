#! pwsh.exe
# Incremental data pipeline
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
# Start jobs to calculate hash values in parallel
$apiJob = Start-Job -ScriptBlock { param($apiEndpoint, $algorithm, $cwd)
    & "$cwd\Calculate-DataHash.ps1" -DataSource $apiEndpoint -Algorithm $algorithm -Mode Validate
    } -ArgumentList $apiEndpoint, $algorithm, $cwd
$fileJob = Start-Job -ScriptBlock { param($localFileName, $algorithm, $cwd)
    & "$cwd\Calculate-DataHash.ps1" -DataSource "$cwd\$localFileName" -Algorithm $algorithm -Mode Validate
    } -ArgumentList $localFileName, $algorithm, $cwd

# Wait for the jobs to complete
Wait-Job -Job $apiJob, $fileJob

# Get the results of the jobs
$apiDataArray = Receive-Job -Job $apiJob
$fileDataArray = Receive-Job -Job $fileJob

# Remove the jobs from the session
Remove-Job -Job $apiJob, $fileJob

# Perform validation checks with the hash values
if ( $apiDataArray[0] -ne $fileDataArray[0] ){
    Write-Host "Data hash changed ... Processing changed data ...." -ForegroundColor Green 
    
    # Start jobs to calculate hash values in parallel
    $apiJob = Start-Job -ScriptBlock { param($apiEndpoint, $algorithm, $cwd)
        & "$cwd\Calculate-DataHash.ps1" -DataSource $apiEndpoint -Algorithm $algorithm -Mode Compare
        } -ArgumentList $apiEndpoint, $algorithm, $cwd
    $fileJob = Start-Job -ScriptBlock { param($localFileName, $algorithm, $cwd)
        & "$cwd\Calculate-DataHash.ps1" -DataSource "$cwd\$localFileName" -Algorithm $algorithm -Mode Compare
        } -ArgumentList $localFileName, $algorithm, $cwd

    # Wait for the jobs to complete
    Wait-Job -Job $apiJob, $fileJob

    # Get the results of the jobs
    $apiDataArray = Receive-Job -Job $apiJob
    $fileDataArray = Receive-Job -Job $fileJob

    # Remove the jobs from the session
    Remove-Job -Job $apiJob, $fileJob

    # Validate API or File I/O request jobs success
    if ( $apiDataArray.Count -eq $fileDataArray.Count -eq 2 ) {

        # Import the file data schema
        $headers = Get-Content -Path ($cwd+"\docschema.json") | ConvertFrom-Json

        # If the hash values are not equal, compare the ref data with the diff data to determine which data has changed
        $changedData = Compare-Object -ReferenceObject $apiDataArray[1] -DifferenceObject $fileDataArray[1] -Property ($headers -join ",").Split(",") -Passthru `
            | Where-Object {$_.SideIndicator -eq "<="}

        Write-Host "Updating CSV document and and API resource hash value ..." -ForegroundColor Green
        # Update CSV document with changed data from API endpoint
        $changedData | Export-Csv -Path "$cwd\$localFileName.csv" -NoTypeInformation -Append
        # Replace JSON document with the API resource hash
        $apiDataArray[0] | ConvertTo-Json | Out-File ("{0}\{1}Hash.json" -f $cwd, $localFileName)
        Write-Host "$localFileName data updated with rows: "$changedData.Count -ForegroundColor Green
    } else {
        # Print error details to console
        @($apiDataArray, $fileDataArray).ForEach{if($_.Count -ne 2){ Write-Host $_ -ForegroundColor Red }}
        Exit 
    }
} else { 
    Write-Host "Data hash unchanged ..." -ForegroundColor Cyan 
}


