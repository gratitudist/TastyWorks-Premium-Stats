# TastyWorks-Premium-Stats

A PowerShell script that calculates premium collected, premium paid, fees, commissions, profit and loss and premium capture rate from TastyWorks history CSV files.

Note: The script doesn't currently account for open v closed positions. So if you have open trades when running the script, keep that in mind.
Note also: This is not affiliated with Tastyworks in any way.

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

### Request to readers:
If you're on a different platform than Tastyworks and have similar CSV output from your platform that you'd like to be able to parse in this way, I'm willing to write a similar script, or even a script that's capable of handling CSV files from multiple platforms. I just need samples CSV files. If this interests you and you're willing to share sample CSVs fro your broker, please let me know. **Please don't send any CSVs with account numbers or personally identifying information.**

