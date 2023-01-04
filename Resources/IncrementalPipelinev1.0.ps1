# Store the API endpoint in a variable
$apiEndpoint = "https://api.coindesk.com/v1/bpi/currentprice.json"

# Use Invoke-RestMethod to retrieve the data from the API
$apiData = Invoke-RestMethod -Uri $apiEndpoint -Method Get

$apiData | ConvertTo-Json | Out-File "C:\Users\ENGR. RICH\Downloads\bpi.json"

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
        $data = Invoke-RestMethod -Uri $DataSource -Method Get

        # Convert the data to a JSON string
        $dataJson = $data | ConvertTo-Json

        # Convert the JSON string to a byte array
        $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($dataJson)
    } else {
        # Data source is a file
        # Read the contents of the file into a string 
        $data = Get-Content -Path $DataSource 

        # Convert the data to a JSON string and round-trip object format
        $dataJson = $data | ConvertFrom-Json | ConvertTo-Json

        # Convert the string to a byte array
        $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($dataJson)
    }

    # Create a new MemoryStream object with the capacity of the byte array
    $dataStream = New-Object System.IO.MemoryStream(,$dataBytes)

    # Calculate the hash of the data streaming object
    $dataHash = (Get-FileHash -InputStream $dataStream -Algorithm $Algorithm).Hash

    # Return the calculated hash value
    return $dataHash
}

# Calculate the data hash values
Calculate-DataHash -DataSource "https://api.coindesk.com/v1/bpi/currentprice.json" -Algorithm SHA256
Calculate-DataHash -DataSource "C:\Users\ENGR. RICH\Downloads\bpi.json" -Algorithm SHA256

