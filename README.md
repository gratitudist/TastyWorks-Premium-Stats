# Stats for options premium sellers:

A PowerShell script that calculates premium sold, premium paid, fees, commissions, profit and loss, premium capture rate and number of trades from TastyWorks history CSV and Fidelity Account_Hisotry.csv files.

Note: The script doesn't currently account for open v closed positions. So if you have open trades when running the script, keep that in mind.
Note also: This is not affiliated with Tastyworks or Fidelity in any way.

Examples:

Tastyworks example:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/2023-01-01_2023-01-13.csv                                              

        Premium Sold :       $3,095.00
        Premium Paid :       $2,365.00
                Fees :          $50.88
         Commissions :          $38.00
       Profit / Loss :         $641.12
Premium Capture Rate :          20.71%
              Trades :              63
```
Fidelity Account_history.csv example:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/Fidelity_Sample.csv      

        Premium Sold :       $3,472.00
        Premium Paid :       $3,162.00
                Fees :           $1.74
         Commissions :          $28.95
       Profit / Loss :         $279.31
Premium Capture Rate :           8.04%
              Trades :              61
```
Example of returning a PowerShell object:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/2023-01-01_2023-01-13.csv -ObjectOut                                   

Premium Sold         : 3095
Premium Paid         : 2365
Fees                 : 50.88
Commissions          : 38
Profit / Loss        : 641.12
Premium Capture Rate : 0.2071
Trades               : 63
```
Example of converting PowerShell output object to CSV data:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/2023-01-01_2023-01-13.csv -ObjectOut | ConvertTo-Csv -NoTypeInformation
"Premium Sold","Premium Paid","Fees","Commissions","Profit / Loss","Premium Capture Rate","Trades"
"3095","2365","50.88","38","641.12","0.2071","63"
```
### Request to readers:
If you're on a different platform than Tastyworks and have similar CSV output from your platform that you'd like to be able to parse in this way, I'm willing to write a similar script, or even a script that's capable of handling CSV files from multiple platforms. I just need samples CSV files. If this interests you and you're willing to share sample CSVs fro your broker, please let me know. 

**Please don't send any CSVs with account numbers or personally identifying information.**
