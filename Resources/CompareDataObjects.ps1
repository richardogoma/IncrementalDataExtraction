# Create a reference object
$referenceObject = (get-content -Path "C:\Users\ENGR. RICH\Downloads\testfile1.txt")

# Calculate the hash of the reference object
$refDataHash = (Get-FileHash "C:\Users\ENGR. RICH\Downloads\testfile1.txt").Hash

# Create a difference object
$differenceObject = (get-content -Path "C:\Users\ENGR. RICH\Downloads\testfile2.txt")

# Calculate the hash of the difference object
$diffDataHash = (Get-FileHash "C:\Users\ENGR. RICH\Downloads\testfile2.txt").Hash

# Compare the hash values
if ($refDataHash -ne $diffDataHash){  

    # If the hash values are not equal, compare the ref data with the diff data to determine which data has changed
    $changedData = Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -PassThru

    # Display the changed data
    $changedData

}

# --------------------------------------------------------------
$wc = [System.Net.WebClient]::new()

# Store the API endpoint in a variable
$apiEndpoint = "https://datausa.io/api/data?drilldowns=Nation&measures=Population"

# Use Invoke-RestMethod to retrieve the data from the API
$apiData = Invoke-RestMethod -Uri $apiEndpoint -Method Get

# Calculate the hash of the API data
$apiDataHash = Get-FileHash -InputStream ($wc.OpenRead($apiEndpoint))

$apiDataHash

# ---------------------------------------------------------------------
# Store the API endpoint in a variable
$apiEndpoint = "https://api.coindesk.com/v1/bpi/currentprice.json"

# Use Invoke-RestMethod to retrieve the data from the API
$apiData = Invoke-RestMethod -Uri $apiEndpoint

$apiData | Out-File "C:\Users\ENGR. RICH\Downloads\bpi.txt"

