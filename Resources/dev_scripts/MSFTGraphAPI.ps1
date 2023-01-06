## OAuth authentication using Microsoft Graph API
## https://developer.microsoft.com/en-us/graph/graph-explorer/preview
$AccessToken = ConvertTo-SecureString 'eyJ0eXAiOiJKV1QiLCJub25jZSI6I...' -AsPlainText -Force

$Params = @{
    "URI" = 'https://graph.microsoft.com/v1.0/me'
    "Method" = 'GET'
    # "Headers" = @{
    #     "Content-Type" = 'application/json'
    #     "Authorization" = 'Bearer'
    # }
    "Authentication" = 'Bearer'
    "Token" = $AccessToken
    "ContentType" = 'application/json'
}

$Response = Invoke-RestMethod @Params
$Response | 
    Select-Object displayName, @{Name="Phone";Expression={$_.businessPhones[0]}}, mail | ConvertTo-Json