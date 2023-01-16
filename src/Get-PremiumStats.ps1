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

function Get-TradeStats {
  param (
    [Parameter(Mandatory=$True,Position=0)]
      [PSObject]$TradeData
  )
  $obj = 0 | Select-Object 'Premium Collected', 'Premium Paid', 'Fees', 'Commissions', 'Profit / Loss', 'Premium Capture Rate'
  $TradeData | ForEach-Object { $row = $_
    switch ($row.Action) {
      'BUY_TO_OPEN' { 
        $obj.'Premium Paid' += [Math]::Abs($row.Value) 
        $obj.'Fees' += [Math]::Abs($row.Fees)
        $obj.'Commissions' += [Math]::Abs($row.Commissions)
      }
      'BUY_TO_CLOSE' { 
        $obj.'Premium Paid' += [Math]::Abs($row.Value) 
        $obj.'Fees' += [Math]::Abs($row.Fees)
      }
      'SELL_TO_OPEN' { 
        $obj.'Premium Collected' += [Math]::Abs($row.Value) 
        $obj.'Fees' += [Math]::Abs($row.Fees)
        $obj.'Commissions' += [Math]::Abs($row.Commissions)
      }
      'SELL_TO_CLOSE' { 
        $obj.'Premium Collected' += [Math]::Abs($row.Value) 
        $obj.'Fees' += [Math]::Abs($row.Fees)
      }
    }
  }
  $obj.Fees = [Math]::Round($obj.Fees, 2)
  $obj.'Profit / Loss' = [Math]::Round((($obj.'Premium Collected' - $obj.'Premium Paid') - $obj.Fees), 2)
  $obj.'Premium Capture Rate' = [Math]::Round((((($obj.'Premium Collected' - $obj.'Premium Paid') - $obj.Fees) / $obj.'Premium Collected') * 100), 2)
  $obj
}

if (Test-Path -Path $InputFile)
{
  $TradeData = Get-TradeData $InputFile
} else {
  Write-Output ("InputFile '{0}' not found." -f $InputFile)
}

Get-TradeStats -TradeData $TradeData
