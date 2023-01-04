# Data Extraction from CoinDesk RESTFul API service
## Purpose
This program is designed to extract data from an API endpoint and save it to a local file in CSV format. If the local file already exists, the program will compare the hash values of the API resource and the local file to determine if there are any changes in the data. If there are changes, the program will pre-process and update the local file with the new data. The data is produced from the CoinDesk Bitcoin Price Index API in real-time.

## Prerequisites
* PowerShell 5.1 or later
* Determine the script execution policy on your machine by executing `Get-ExecutionPolicy` in terminal. The execution policy in PowerShell has to be changed from `Restricted` to enable you run PowerShell scripts. Run `Set-ExecutionPolicy -ExecutionPolicy Unsigned -Scope CurrentUser` on terminal.  
* The script requires the `Invoke-RestMethod `cmdlet to retrieve data from the API endpoint, the `Get-FileHash` cmdlet to calculate the hash values of the data and the `Compare-Object` cmdlet to return the changed data. These cmdlets are part of the PowerShell core and should be available in any modern version of PowerShell.
* Authentication is not required to access the API resource.

## Inputs
* `$algorithm`: A string that specifies the hashing algorithm to use for calculating the hash values. The following algorithms are supported: MD5, SHA1, SHA256, SHA384, SHA512. The program uses `SHA256`. 
* `cwd`: A string value representing the current working directory. This is used to locate the script file, `Calculate-DataHash.ps1`, that contains the `Get-DataHash` function. The batch program, `Executor.bat`, defaults to the current working directory; this should be modified to where the program was unbundled. 

## Outputs
* `BitcoinPriceIndex.csv`: A CSV file containing the extracted data in a tabular format. The file will be saved in the current working directory.
* `BitcoinPriceIndexHash.json`: A JSON file containing the hash value of the local CSV file. The file will be saved in the current working directory.

## Usage
```powershell
# Execute or create a job to run the batch program
cmd /c Executor.bat
```
When the program is run for the first time, it would execute the script, `Extract-FullDatav1.2.2.ps1` to perform a full batch data extraction of data from the API resource. Subsequent runs of the program, the script, `Extract-IncrementalDatav1.2.2.ps1` would be executed to perform incremental data extraction if the data has changed and the hash value is different. 

![incremental data extraction]( ./Resources/Screenshot%202023-01-04%20182917.png )

## Notes
Full batch data extraction is a process of extracting all the data from a data source in one go. It involves retrieving all the data from the source and saving it locally. This is useful in situations where the data is needed for the first time or when the data needs to be updated completely.

On the other hand, incremental data extraction is a process of extracting only the data that has changed since the last extraction. It involves comparing the data from the source with the locally saved data and extracting only the changed data. This is useful in situations where the data changes frequently and only the changes need to be processed.

The program performs both full batch and incremental data extraction from an API endpoint. The `Get-DataHash` function is used to calculate the hash value of the data from the API endpoint or a local file and return the data.

The full batch data extraction script starts by setting the variables for the API endpoint and local file name. It then starts a job to calculate the hash value and return the API endpoint resource using the `Get-DataHash` function. The script waits for the job to complete and gets the results of the job. It then checks if the count of the results is 2, indicating that both the hash value and data were returned. If the count is 2, the script writes the data to a CSV file and the hash value to a JSON file. It then displays a message indicating that the CSV and JSON files were created.

The incremental data extraction script starts by setting the variables for the API endpoint and local file name. It then starts a job to calculate the hash value and return the API endpoint resource using the `Get-DataHash` function. The script waits for the job to complete and gets the results of the job. It then reads the JSON file containing the hash value of the previously saved data. If the hash values of the API endpoint resource and the locally saved data are not equal, the script retrieves the changed data using the `Compare-Object` cmdlet. It then writes the changed data to a CSV file and the updated hash value to a JSON file. It then displays a message indicating that the CSV and JSON files were updated.

To use the program, the user needs to provide the algorithm to be used for calculating the hash value and the current working directory as arguments when running the script. The script will then handle the rest of the data extraction process.

## Pre-processed Data Shape
This program could easily become part of either a data intergration or data management system, functioning as a microservice. The pre-processed data could be used by other services within the data management system to perform various tasks, such as data analysis, reporting, app development and more.

The data is structured in columnar format and can be easily consumed. The data schema/headers is represented in `docschema.json`.

| chartName | EUR | GBP | USD | updatedtimeISO| 
|-----------|-----|-----|-----|----------------|
| Bitcoin | 16211.2575 | 13905.5101 | 16641.507 | 04-Jan-23 1:49:00 AM| 
| Bitcoin | 16215.5825 | 13909.2199 | 16645.9468 | 04-Jan-23 2:02:00 AM| 
| Bitcoin | 16246.5755 | 13935.8048 | 16677.7624 | 04-Jan-23 2:16:00 AM| 

## References
* [CoinDesk Bitcoin Price Index API](https://api.coindesk.com/v1/bpi/currentprice.json)
* [MD5 vs SHA-1 vs SHA-2 - Which is the Most Secure Encryption Hash and How to Check Them](https://www.freecodecamp.org/news/md5-vs-sha-1-vs-sha-2-which-is-the-most-secure-encryption-hash-and-how-to-check-them/)
* [about_Script_Blocks](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_script_blocks?view=powershell-7.3)
* [How To Get The Value Of Header In CSV](https://stackoverflow.com/questions/25764366/how-to-get-the-value-of-header-in-csv)
* [Passing an array of bytes to system.IO.MemoryStream](https://scriptingetc.wordpress.com/2019/05/22/passing-an-array-of-bytes-to-system-io-memorystream/)
* [PowerShell Notes for Professionals](https://media.licdn.com/dms/document/C4D1FAQFZ9M2LYEvS7Q/feedshare-document-pdf-analyzed/0/1672583589997?e=1673481600&v=beta&t=odZOzH-VJbNUt2qVGEVPm1Mk8s-LXmDuGmDO9uJ4zlw)
* [PowerShell for Beginners - BY ALEX RODRICK](https://f.hubspotusercontent20.net/hubfs/4890073/PowerShell%20for%20Beginners%20eBook.pdf)



