# Stats for options premium sellers:

A PowerShell script that calculates premium sold, premium paid, fees, commissions, profit and loss, premium capture rate and number of trades from TastyWorks history CSV and Fidelity Account_Hisotry.csv files.

Note: The script doesn't currently account for open v closed positions. So if you have open trades when running the script, keep that in mind.
Note also: This is not affiliated with Tastyworks or Fidelity in any way.

### New:
Recently added trade type information to the output. This may be useful for determining win rates, how many short positions were stopped out, etc.

Examples:

Tastyworks example:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/tastyworks_sample.csv

        Premium Sold :       $3,095.00
        Premium Paid :       $2,365.00
                Fees :          $50.88
         Commissions :          $38.00
       Profit / Loss :         $641.12
Premium Capture Rate :          20.71%
              Trades :              63
   Long Calls Opened :               6
   Long Calls Closed :               1
  Short Calls Opened :              12
  Short Calls Closed :              12
    Long Puts Opened :               5
    Long Puts Closed :               0
   Short Puts Opened :              14
   Short Puts Closed :              13
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
   Long Calls Opened :               2
   Long Calls Closed :               2
  Short Calls Opened :               3
  Short Calls Closed :               4
    Long Puts Opened :               4
    Long Puts Closed :               4
   Short Puts Opened :              20
   Short Puts Closed :              22
```
Example of returning a PowerShell object:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/tastyworks_sample.csv -ObjectOut

Premium Sold         : 3095
Premium Paid         : 2365
Fees                 : 50.88
Commissions          : 38
Profit / Loss        : 641.12
Premium Capture Rate : 0.2071
Trades               : 63
Long Calls Opened    : 6
Long Calls Closed    : 1
Long Puts Opened     : 5
Long Puts Closed     : 0
Short Calls Opened   : 12
Short Calls Closed   : 12
Short Puts Opened    : 14
Short Puts Closed    : 13
```
Example of converting PowerShell output object to CSV data:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/tastyworks_sample.csv -ObjectOut | ConvertTo-Csv -NoTypeInformation
"Premium Sold","Premium Paid","Fees","Commissions","Profit / Loss","Premium Capture Rate","Trades","Long Calls Opened","Long Calls Closed","Long Puts Opened","Long Puts Closed","Short Calls Opened","Short Calls Closed","Short Puts Opened","Short Puts Closed"
"3095","2365","50.88","38","641.12","0.2071","63","6","1","5","0","12","12","14","13"
```
### Request to readers:
If you're on a different platform than Tastyworks and have similar CSV output from your platform that you'd like to be able to parse in this way, I'm willing to write a similar script, or even a script that's capable of handling CSV files from multiple platforms. I just need samples CSV files. If this interests you and you're willing to share sample CSVs fro your broker, please let me know. 

**Please don't send any CSVs with account numbers or personally identifying information.**
