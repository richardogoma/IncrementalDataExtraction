--Add Exchange Rates Data
BULK INSERT [dbo].[ExchangeRates] FROM 'D:\NLNG\Work\Csv\ExchangeRates.csv' WITH
(
	DATAFILETYPE = 'widechar'
	,FIRSTROW = 2
	,FIELDTERMINATOR = ','
	,ROWTERMINATOR = '\n'
	,TABLOCK
    ,FORMAT = 'CSV'
    ,FIELDQUOTE = '"'
);
GO