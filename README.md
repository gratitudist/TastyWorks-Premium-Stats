# TastyWorks-Premium-Stats

A PowerShell script that calculates premium collected, premium paid, fees, commissions, profit and loss and premium capture rate from TastyWorks history CSV files.

Example:

```
./src/Get-PremiumStats.ps1 -InputFile ./tests/2023-01-01_2023-01-13.csv                                              

   Premium Collected :       $3,095.00
        Premium Paid :       $2,365.00
                Fees :          $50.88
         Commissions :          $38.00
       Profit / Loss :         $641.12
Premium Capture Rate :          20.71%
```

Get-PremiumStats.ps1 can also be run with the `-ObjectOut` flag, which will return a PowerShell object suitable for conversion to CSV, other formats or additional processing:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/2023-01-01_2023-01-13.csv -ObjectOut

Premium Collected    : 3095
Premium Paid         : 2365
Fees                 : 50.88
Commissions          : 38
Profit / Loss        : 641.12
Premium Capture Rate : 0.2071
```

