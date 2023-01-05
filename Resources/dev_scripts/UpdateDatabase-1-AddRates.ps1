Write-Host -foreground green 'Inserting Exchange Rates Data...'

Invoke-SqlCmd -Server localhost -Database "NLNGProjects" -InputFile "D:\NLNG\Work\Script\UpdateDatabase-1.sql"

Write-Host -foreground green 'Discarding CSV file...'
# $z = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Remove-Item -Path D:\NLNG\Work\Csv\ExchangeRates.csv