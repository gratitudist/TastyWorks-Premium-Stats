[CmdletBinding()]
Param
(
  [Parameter(Mandatory=$False,Position=0)]
    [String]$InputFile='tests/2023-01-01_2023-01-13.csv'
)

function Get-TradeData {
  Param (
    [Parameter(Mandatory=$True,Position=0)]
      [String]$DataFile
  )
  Import-Csv $DataFile
}

function Get-Premium {
  param (
    [Parameter(Mandatory=$True,Position=0)]
      [PSObject]$TradeData,
    [Parameter(Mandatory=$True,Position=1)]
      [ValidateSet('Collected', 'Paid')]
      [String]$Action
  )
  switch ($Action)
  {
    'Collected' { $Act = 'SELL_TO_OPEN' }
    'Paid' { $Act = 'BUY_TO_CLOSE' }
  }

  [Math]::Abs( $($TradeData | Where-Object { 
    $_.Action -eq $Act
  } | Measure-Object -Sum Value | Select-Object -ExpandProperty Sum))
}

function Get-PremiumStat {
  param (
    [Parameter(Mandatory=$True,Position=0)]
      [Int32]$Collected,
    [Parameter(Mandatory=$True,Position=1)]
      [Int32]$Paid,
    [Parameter(Mandatory=$True,Position=2)]
      [ValidateSet('PL', 'PCR')]
      [String]$Stat
  )
  switch ($Stat)
  {
    'PCR' { [Math]::Round(((($Collected - $Paid) / $Collected) * 100), 2) }
    'PL'  { $Collected - $Paid }
  }
}

if (Test-Path -Path $InputFile)
{
  $TradeData = Get-TradeData $InputFile
} else {
  Write-Output ("InputFile '{0}' not found." -f $InputFile)
}

$obj = "" | Select-Object 'Premium Collected','Premium Paid','Profit / Loss','Premium Capture Rate'
$obj."Premium Collected" = Get-Premium $TradeData 'Collected'
$obj."Premium Paid" = Get-Premium $TradeData 'Paid'
$obj."Profit / Loss" = Get-PremiumStat $obj."Premium Collected" $obj."Premium Paid" 'PL'
$obj."Premium Capture Rate" = Get-PremiumStat $obj."Premium Collected" $obj."Premium Paid" 'PCR'

Write-Output $obj
