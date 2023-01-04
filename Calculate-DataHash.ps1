using namespace System.Net

Param(
   [string]$DataSource,
   [string]$Algorithm, 
   [string]$Mode
)

# Resolve Proxy Authentication error when making HTTP requests using PowerShell
$browser = New-Object WebClient 
$browser.Proxy.Credentials = [CredentialCache]::DefaultNetworkCredentials 

# ------------------------------------------------
function Get-DataHash {
    param(
        [Parameter(Mandatory)]
        [String]
        $DataSource,

        [Parameter(Mandatory)]
        [ValidateSet("MD5", "SHA1", "SHA256", "SHA384", "SHA512")]
        [String]
        $Algorithm, 

        [Parameter(Mandatory)]
        [ValidateSet("Validate", "Compare")]
        [String]
        $Mode
    )
    try {
        # Check if the data source is an API endpoint or a file
        if ($DataSource -match "^https?://") {
            # Data source is an API endpoint
            # Use Invoke-WebRequest to retrieve API resource
            $response = Invoke-WebRequest -Uri $DataSource -Method Get -OutFile $null -ContentType "application/json"
            $data = if ( $Mode -eq "Validate" ){ $null } else { $response.Content | ConvertFrom-Json | Select-Object -ExcludeProperty disclaimer -ExpandProperty bpi |`
                    Select-Object chartName, 
                                    @{Name='USD'; Expression={$_.USD.rate_float}},
                                    @{Name='GBP'; Expression={$_.GBP.rate_float}},
                                    @{Name='EUR'; Expression={$_.EUR.rate_float}},
                                    @{Name='updatedtimeISO'; Expression={$_.time.updatedISO}} }

            # Calculate the hash of the API resource stream
            $dataHash = (Get-FileHash -InputStream ($response.RawContentStream) -Algorithm $Algorithm).Hash
        } else {
            # Data source is a file        
            # Read the contents of the file into an object 
            $data = if ( $Mode -eq "Validate" ){ $null } else { Get-Content -Path ($DataSource+".csv") | ConvertFrom-Csv }
            $dataHash = Get-Content -Path ("{0}Hash.json" -f $DataSource) | ConvertFrom-Json
        }
        # Return the calculated hash value
        return @($dataHash, $data)
    }
    catch {
        return $_.ErrorDetails
    }
}
Get-DataHash -DataSource $DataSource -Algorithm $Algorithm -Mode $Mode
