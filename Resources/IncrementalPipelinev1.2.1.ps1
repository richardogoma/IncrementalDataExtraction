<# Full batch
# Store the API endpoint in a variable
$apiEndpoint = "https://api.coindesk.com/v1/bpi/currentprice.json"

# Use Invoke-RestMethod to retrieve the data from the API
$apiData = Invoke-RestMethod -Uri $apiEndpoint -Method Get

$bpiUSD = $apiData.bpi.USD
$bpiUSD | ConvertTo-Json | Out-File "C:\Users\ENGR. RICH\Downloads\bpiUSD.json"
$bpiUSD | Export-Csv -Path "C:\Users\ENGR. RICH\Downloads\bpiUSD.csv" -NoTypeInformation  #>

# ---------------------------------------------


$apiEndpoint = "https://api.coindesk.com/v1/bpi/currentprice.json"
$localFileName = "bpiUSD"
$algorithm = "MD5"
$cwd = "C:\Users\ENGR. RICH\Downloads"

# Start jobs to calculate hash values in parallel
$apiJob = Start-Job -ScriptBlock { param($apiEndpoint, $algorithm, $cwd)
    & "$cwd\Calculate-DataHash.ps1" -DataSource $apiEndpoint -Algorithm $algorithm
    } -ArgumentList $apiEndpoint, $algorithm, $cwd
$fileJob = Start-Job -ScriptBlock { param($localFileName, $algorithm, $cwd)
    & "$cwd\Calculate-DataHash.ps1" -DataSource "$cwd\$localFileName.json" -Algorithm $algorithm
    } -ArgumentList $localFileName, $algorithm, $cwd

# Wait for the jobs to complete
Wait-Job -Job $apiJob, $fileJob

# Get the results of the jobs
$apiDataArray = Receive-Job -Job $apiJob
$fileDataArray = Receive-Job -Job $fileJob

# Remove the jobs from the session
Remove-Job -Job $apiJob, $fileJob

# Compare the hash values
if ($apiDataArray[0] -ne $fileDataArray[0]){  

    # If the hash values are not equal, compare the ref data with the diff data to determine which data has changed
    $changedData = Compare-Object $apiDataArray[1] $fileDataArray[1] -Property code, symbol, rate, description, rate_float -Passthru `
        | Where-Object {$_.SideIndicator -eq "<="}

    Write-Host "Updating CSV and JSON files with data ..." -ForegroundColor Green
    # Display the changed data
    $changedData | Format-Table

    # Update CSV document with changed data from API endpoint
    $changedData | Export-Csv -Path "$cwd\$localFileName.csv" -NoTypeInformation -Append
    # Replace JSON document with the API JSON data
    $apiDataArray[2] | Out-File "$cwd\$localFileName.json"

} else { 
    Write-Host "Data unchanged ..." -ForegroundColor Cyan 
}



