# TastyWorks-Premium-Stats

A PowerShell script for calculating premium collected, paid, profit and loss and premium capture rate from TastyWorks history CSV files.

Example:

```
Get-PremiumStats.ps1 -InputFile ./tests/2023-01-01_2023-01-13.csv | fl                                                                              

Premium Collected    : 3095
Premium Paid         : 2365
Fees                 : 50.88
Commissions          : 38
Profit / Loss        : 679.12
Premium Capture Rate : 21.94
```

