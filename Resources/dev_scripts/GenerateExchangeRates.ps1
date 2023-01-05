## Currency Conversion and Exchange Rates API Documentation
## https://rapidapi.com/principalapis/api/currency-conversion-and-exchange-rates
$Params = @{
    "Uri" = 'https://currency-conversion-and-exchange-rates.p.rapidapi.com/latest?from=USD&to=EUR%2CGBP'
    "Method" = 'Get'
    "Headers" = @{
        "ContentType" = 'application/json'
        'Authorization' = 'Bearer <AccessToken>'
        "X-RapidAPI-Key" = 'c892889770msh34b4611091f1e65p1b3a02jsnaca2efec6843'
        "X-RapidAPI-Host" = 'currency-conversion-and-exchange-rates.p.rapidapi.com'
    }
}
$response = Invoke-RestMethod @Params 
$response | 
    Select-Object timestamp, base, success, date, `
        @{Name = "USD"; Expression = {$_.rates.USD}}, `
        @{Name = "GBP"; Expression = {$_.rates.GBP}}, `
        @{Name = "NGN"; Expression = {$_.rates.NGN}}, `
        @{Name = "EUR"; Expression = {$_.rates.EUR}} | 
        ConvertTo-Csv -NoTypeInformation | Out-File D:\NLNG\Work\Csv\ExchangeRates.csv
