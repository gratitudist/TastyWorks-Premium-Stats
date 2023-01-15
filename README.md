# TastyWorks-Premium-Stats

A PowerShell script for calculating premium collected, paid, profit and loss and premium capture rate from TastyWorks history CSV files.

Example:

```
Get-PremiumStats.ps1 -InputFile ./tests/2023-01-01_2023-01-13.csv | fl                                                                              

Premium Collected    : 3065
Premium Paid         : 2280
Profit / Loss        : 785
Premium Capture Rate : 25.61
```

