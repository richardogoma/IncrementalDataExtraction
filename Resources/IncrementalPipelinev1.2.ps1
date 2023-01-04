<# Full batch
# Store the API endpoint in a variable
$apiEndpoint = "https://api.coindesk.com/v1/bpi/currentprice.json"

# Use Invoke-RestMethod to retrieve the data from the API
$apiData = Invoke-RestMethod -Uri $apiEndpoint -Method Get

$bpiUSD = $apiData.bpi.USD
$bpiUSD | ConvertTo-Json | Out-File "C:\Users\ENGR. RICH\Downloads\bpiUSD.json"
$bpiUSD | Export-Csv -Path "C:\Users\ENGR. RICH\Downloads\bpiUSD.csv" -NoTypeInformation  #>

<# Examine byte arrays
# Read the contents of the file into a string 
$filedata = Get-Content -Path "C:\Users\ENGR. RICH\Downloads\bpiUSD.json" | ConvertFrom-Json 
$filejson = $filedata | ConvertTo-Json
[System.Text.Encoding]::UTF8.GetBytes($filejson) | Out-File "C:\Users\ENGR. RICH\Downloads\studyfile.txt"


# Use Invoke-RestMethod to retrieve the data from the API
$apidata = (Invoke-RestMethod -Uri "https://api.coindesk.com/v1/bpi/currentprice.json" -Method Get).bpi.USD
$apijson = $apidata | ConvertTo-Json
[System.Text.Encoding]::UTF8.GetBytes($apijson) | Out-File "C:\Users\ENGR. RICH\Downloads\studyapi.txt"  #>

# ---------------------------------------------

function Calculate-DataHash {
    param(
        [Parameter(Mandatory)]
        [String]
        $DataSource,

        [Parameter(Mandatory)]
        [ValidateSet("MD5", "SHA1", "SHA256", "SHA384", "SHA512")]
        [String]
        $Algorithm
    )

    # Check if the data source is an API endpoint or a file
    if ($DataSource -match "^https?://") {
        # Data source is an API endpoint
        # Use Invoke-RestMethod to retrieve the data from the API
        $data = (Invoke-RestMethod -Uri $DataSource -Method Get -OutFile $null ).bpi.USD

        # Convert the data to a JSON string
        $dataJson = $data | ConvertTo-Json

        <# converting the data to a JSON document can be useful because it allows you to represent the data as a flat JSON string 
        that can be easily converted to a byte array.#>

        # Convert the JSON string to a byte array
        $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($dataJson)
    } else {
        # Data source is a file
        # Read the contents of the file into a string 
        $data = Get-Content -Path $DataSource | ConvertFrom-Json 

        # Convert the data to a JSON string and round-trip object
        $dataJson = $data | ConvertTo-Json

        <# round-tripping is used to ensure that the data is correctly serialized and deserialized; 
        Serialization is the process of converting an object or objects to a data format that can be stored or transmitted, e.g. JSON #>

        # Convert the string to a byte array
        $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($dataJson)
    }

    # Create a new MemoryStream object (or bitmapped object) with the byte array
    $dataStream = New-Object System.IO.MemoryStream(,$dataBytes)

    # Calculate the hash of the data streaming object
    $dataHash = (Get-FileHash -InputStream $dataStream -Algorithm $Algorithm).Hash

    # Return the calculated hash value
    return @($dataHash, $data, $dataJson)
}

# Calculate the data hash values
$apiDataArray = Calculate-DataHash -DataSource "https://api.coindesk.com/v1/bpi/currentprice.json" -Algorithm SHA256
$fileDataArray = Calculate-DataHash -DataSource "C:\Users\ENGR. RICH\Downloads\bpiUSD.json" -Algorithm SHA256

# Compare the hash values
if ($apiDataArray[0] -ne $fileDataArray[0]){  
    
    Write-Host "Hash values not equal"

    # If the hash values are not equal, compare the ref data with the diff data to determine which data has changed
    $changedData = Compare-Object $apiDataArray[1] $fileDataArray[1] -Property code, symbol, rate, description, rate_float -Passthru

    # Display the changed data
    $changedData | Format-Table

    # Update CSV document with changed data from API endpoint
    $changedData | ForEach-Object {

        if ($_.SideIndicator -eq "<="){

            Write-Host "Updating file with : "$_
            $_ | Export-Csv -Path "C:\Users\ENGR. RICH\Downloads\bpiUSD.csv" -NoTypeInformation -Append

         }
    }

    # Replace JSON document with the API JSON data
    $apiDataArray[2] | Out-File "C:\Users\ENGR. RICH\Downloads\bpiUSD.json"

}







