Param(
   [string]$DataSource,
   [string]$Algorithm
)

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
        # Use Invoke-WebRequest to retrieve the data from the API
        $response = Invoke-WebRequest -Uri $DataSource -Method Get -OutFile $null
        $data = ($response.Content | ConvertFrom-Json).bpi.USD

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
Calculate-DataHash -DataSource $DataSource -Algorithm $Algorithm
