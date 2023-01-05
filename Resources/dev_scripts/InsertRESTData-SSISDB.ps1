# Create SQLConnection object
try {
    $SqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection
	$SqlConnection.ConnectionString = "Server=localhost;Database=NLNGProjects;Trusted_Connection=True;"
	$SqlConnection.Open()
}
catch {
    $_.Exception.Response
}


if ($SqlConnection.State -eq [System.Data.ConnectionState]::Open) {

	# Create SqlCommand object
	$SqlCommand = $SqlConnection.CreateCommand() # returns System.Data.SqlClient.SqlCommand
	$SqlCommand.CommandTimeOut = 30

    # Consume REST API Service data
    try {
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
                @{Name = "EUR"; Expression = {$_.rates.EUR}}

        # Update table with REST data
        foreach($obj in $response) {  
            $SqlCommand.CommandText = "INSERT [dbo].[ExchangeRates] VALUES (@timestamp, @base, @success, @date, @USD, @GBP, @NGN, @EUR)"  
        
            # Pass parameter values to the SQL command
            $SqlCommand.Parameters.AddWithValue("@timestamp", $obj.timestamp);  
            $SqlCommand.Parameters.AddWithValue("@base", $obj.base);  
            $SqlCommand.Parameters.AddWithValue("@success", $obj.success);  
            $SqlCommand.Parameters.AddWithValue("@date", $obj.date);  
            $SqlCommand.Parameters.AddWithValue("@USD", $obj.rates.USD);  
            $SqlCommand.Parameters.AddWithValue("@GBP", $obj.rates.GBP);  
            $SqlCommand.Parameters.AddWithValue("@NGN", $obj.rates.NGN);  
            $SqlCommand.Parameters.AddWithValue("@EUR", $obj.rates.EUR); 
    
            # Execute a Transact-SQL statement against the connection and returns the number of rows affected
            $RowsAffected = $SqlCommand.ExecuteNonQuery()
            
            # Print the number of rows inserted into the table
            Write-Host -ForegroundColor Green "Updating table with REST API Service data ... Rows affected: $RowsAffected"

            # Clear parameters passed into sql command
            $SqlCommand.Parameters.clear();  
        } 
    }
    catch {
        $_.Exception.Response
    }
    finally {
        Write-Host -ForegroundColor Red 'Table updated; Closing Sql connection ....'
        $SqlConnection.Close()
    }
};
