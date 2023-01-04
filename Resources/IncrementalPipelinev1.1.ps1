# Store the API endpoint in a variable
$apiEndpoint = "https://api.coindesk.com/v1/bpi/currentprice.json"

# Use Invoke-RestMethod to retrieve the data from the API
$apiData = Invoke-RestMethod -Uri $apiEndpoint -Method Get

$apiData.bpi.USD | Select-Object code, symbol, rate, description, rate_float | Export-Csv -Path "C:\Users\ENGR. RICH\Downloads\bpiUSD.csv" -NoTypeInformation

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
        $data = (Invoke-RestMethod -Uri $DataSource -Method Get).bpi.USD | Select-Object code, symbol, rate, description, rate_float

        # Convert the data to a JSON string
        $dataJson = $data | ConvertTo-Json

        # Convert the JSON string to a byte array
        $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($dataJson)
    } else {
        # Data source is a file
        # Read the contents of the file into a string 
        $data = Get-Content -Path $DataSource | ConvertFrom-Csv 

        # Convert the data to a JSON string and round-trip object format
        $dataJson = $data | ConvertTo-Json

        # Convert the string to a byte array
        $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($dataJson)
    }

    # Create a new MemoryStream object with the capacity of the byte array
    $dataStream = New-Object System.IO.MemoryStream(,$dataBytes)

    # Calculate the hash of the data streaming object
    $dataHash = (Get-FileHash -InputStream $dataStream -Algorithm $Algorithm).Hash

    # Return the calculated hash value
    return @($dataHash, $data)
}

# Calculate the data hash values
$apiDataArray = Calculate-DataHash -DataSource "https://api.coindesk.com/v1/bpi/currentprice.json" -Algorithm SHA256
$fileDataArray = Calculate-DataHash -DataSource "C:\Users\ENGR. RICH\Downloads\bpiUSD.csv" -Algorithm SHA256

# Compare the hash values
if ($apiDataArray[0] -ne $fileDataArray[0]){  

    $true

    # If the hash values are not equal, compare the ref data with the diff data to determine which data has changed
    # $changedData = Compare-Object -ReferenceObject $apiDataArray[1] -DifferenceObject $fileDataArray[1] 
    $changedData = Compare-Object $apiDataArray[1] $fileDataArray[1] -Property code, symbol, rate, description, rate_float -Passthru

    # Display the changed data
    $changedData | Format-Table
}