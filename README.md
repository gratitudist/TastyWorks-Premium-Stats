# Stats for options premium sellers:

A PowerShell script that calculates premium sold, premium paid, fees, commissions, profit and loss, premium capture rate and number of trades from TastyWorks history CSV and Fidelity Account_Hisotry.csv files.

Note: The script doesn't currently account for open v closed positions. So if you have open trades when running the script, keep that in mind.
Note also: This is not affiliated with Tastyworks or Fidelity in any way.

### New:
Added trade type information to the output. This may be useful for determining win rates, how many short positions were stopped out, etc.<br />
Added -Details flag to control the"pretty print" output of the above trade details. Object output will always include these details.<br />
Added win rate properties for short calls and puts.<br />
*Please note:* The win rate calculations are overly naive at this point and the code needs to be made more accurate. Wins are currently based purely on short positions being opened without being closed, assuming they expired worthless, which is obviously not always the case. The short position could be closed early for a profit or expire in the money. I'm working on a robust solution, but it will take some time. 
Examples:

Tastyworks example without details:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/tastyworks_sample.csv

        Premium Sold:       $3,095.00
        Premium Paid:       $2,365.00
                Fees:          $50.88
         Commissions:          $38.00
       Profit / Loss:         $641.12
Premium Capture Rate:          20.71%
              Trades:              63
 Short Call Win Rate:           0.00%
  Short Put Win Rate:           7.14%
```
Tastyworks example with details:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/tastyworks_sample.csv -Details

        Premium Sold:       $3,095.00
        Premium Paid:       $2,365.00
                Fees:          $50.88
         Commissions:          $38.00
       Profit / Loss:         $641.12
Premium Capture Rate:          20.71%
              Trades:              63
   Long Calls Opened:               6
   Long Calls Closed:               1
  Short Calls Opened:              12
  Short Calls Closed:              12
    Long Puts Opened:               5
    Long Puts Closed:               0
   Short Puts Opened:              14
   Short Puts Closed:              13
 Short Call Win Rate:           0.00%
  Short Put Win Rate:           7.14%
```
Fidelity Account_history.csv example:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/Fidelity_Sample.csv

        Premium Sold:       $3,472.00
        Premium Paid:       $3,162.00
                Fees:           $1.74
         Commissions:          $28.95
       Profit / Loss:         $279.31
Premium Capture Rate:           8.04%
              Trades:              61
 Short Call Win Rate:         -33.33%
  Short Put Win Rate:         -10.00%
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
Short Call Win Rate  : 0
Short Put Win Rate   : 0.0714
```
Example of converting PowerShell output object to CSV data:
```
./src/Get-PremiumStats.ps1 -InputFile ./tests/tastyworks_sample.csv -ObjectOut | ConvertTo-Csv -NoTypeInformation
"Premium Sold","Premium Paid","Fees","Commissions","Profit / Loss","Premium Capture Rate","Trades","Long Calls Opened","Long Calls Closed","Long Puts Opened","Long Puts Closed","Short Calls Opened","Short Calls Closed","Short Puts Opened","Short Puts Closed","Short Call Win Rate","Short Put Win Rate"
"3095","2365","50.88","38","641.12","0.2071","63","6","1","5","0","12","12","14","13","0","0.0714"
```
### Request to readers:
If you're on a different platform than Tastyworks and have similar CSV output from your platform that you'd like to be able to parse in this way, I'm willing to write a similar script, or even a script that's capable of handling CSV files from multiple platforms. I just need samples CSV files. If this interests you and you're willing to share sample CSVs fro your broker, please let me know. 

**Please don't send any CSVs with account numbers or personally identifying information.**
