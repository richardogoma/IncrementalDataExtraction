# Data Extraction from an API Endpoint
## Purpose
This program is designed to extract data from an API endpoint and save it to a local file in CSV format. If the local file already exists, the program will compare the hash values of the API resource and the local file to determine if there are any changes in the data. If there are changes, the program will pre-process and update the local file with the new data. The data is produced from the CoinDesk Bitcoin Price Index API in real-time.

## Prerequisites
* PowerShell 5.1 or later
* The execution policy in PowerShell has to unset from `Restricted`, for example, `Set-ExecutionPolicy -ExecutionPolicy Unsigned -Scope CurrentUser`. To determine the current execution policy, run `get-executionpolicy` in terminal. 
* The script requires the `Invoke-RestMethod `cmdlet to retrieve data from the API endpoint, the `Get-FileHash` cmdlet to calculate the hash values of the data and the `Compare-Object` cmdlet to return the changed data. These cmdlets are part of the PowerShell core and should be available in any modern version of PowerShell.

## Inputs
* `$algorithm`: A string that specifies the hashing algorithm to use for calculating the hash values. The following algorithms are supported: MD5, SHA1, SHA256, SHA384, SHA512. The program uses `SHA256`. 
* `cwd`: A string value representing the current working directory. This is used to locate the script file that contains the `Get-DataHash` function. The batch program, `Executor.bat`, defaults to the current working directory; this should be modified to where the program was unbundled. 

## Outputs
* `BitcoinPriceIndex.csv`: A CSV file containing the extracted data in a tabular format. The file will be saved in the current working directory.
* `BitcoinPriceIndexHash.json`: A JSON file containing the hash value of the local CSV file. The file will be saved in the current working directory.

## Usage
```powershell
# Execute or create a job to run the batch program
cmd /c executor.bat
```
When the program is run for the first time, it would perform a full batch data extraction of data from the API resource. Subsequent runs of the program would be incremental data extraction if the data has changed and the hash value is different. 

## Notes
Full batch data extraction is a process of extracting all the data from a data source in one go. It involves retrieving all the data from the source and saving it locally. This is useful in situations where the data is needed for the first time or when the data needs to be updated completely.

On the other hand, incremental data extraction is a process of extracting only the data that has changed since the last extraction. It involves comparing the data from the source with the locally saved data and extracting only the changed data. This is useful in situations where the data changes frequently and only the changes need to be processed.

The program performs both full batch and incremental data extraction from an API endpoint. The `Get-DataHash` function is used to calculate the hash value of the data from the API endpoint or a local file and return the data.

The full batch data extraction script starts by setting the variables for the API endpoint and local file name. It then starts a job to calculate the hash value and return the API endpoint resource using the `Get-DataHash` function. The script waits for the job to complete and gets the results of the job. It then checks if the count of the results is 2, indicating that both the hash value and data were returned. If the count is 2, the script writes the data to a CSV file and the hash value to a JSON file. It then displays a message indicating that the CSV and JSON files were created.

The incremental data extraction script starts by setting the variables for the API endpoint and local file name. It then starts a job to calculate the hash value and return the API endpoint resource using the `Get-DataHash` function. The script waits for the job to complete and gets the results of the job. It then reads the JSON file containing the hash value of the previously saved data. If the hash values of the API endpoint resource and the locally saved data are not equal, the script retrieves the changed data using the `Compare-Object` cmdlet. It then writes the changed data to a CSV file and the updated hash value to a JSON file. It then displays a message indicating that the CSV and JSON files were updated.

To use the program, the user needs to provide the algorithm to be used for calculating the hash value and the current working directory as arguments when running the script. The script will then handle the rest of the data extraction process.

## References
* [Get-FileHash](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-7.3)
* [Compare-Object](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object?view=powershell-7.3)
* [Invoke-RestMethod](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.3)
* [Passing an array of bytes to system.IO.MemoryStream](https://scriptingetc.wordpress.com/2019/05/22/passing-an-array-of-bytes-to-system-io-memorystream/)
* [OpenAI](https://chat.openai.com/chat/d3a1604e-62f5-4a8d-b846-e83a8350f28c)
