[CmdletBinding()]
Param
(
  [Parameter(Mandatory=$False,Position=0)]
    [String]$InputFile='tests/tastyworks_sample.csv',
  [Parameter(Mandatory=$False,Position=1)]
    [Switch]$ObjectOut=$False,
  [Parameter(Mandatory=$False,Position=2)]
    [String]$FileType,
  [Parameter(Mandatory=$False,Position=3)]
    [Switch]$Details=$False
)

function Get-FileType {
  param(
    [Parameter(Mandatory=$True,Position=0)]
      [String]$InputFile
  )
  $Reader = New-Object System.IO.StreamReader($InputFile)
  do
  {
    $line = $Reader.ReadLine()
  } while ($line.Length -eq 0)
  switch -Wildcard ($line) {
    'Date,Type,Action,Symbol,Instrument*' {
      'Tastyworks'
    }
    'Brokerage' {
      'Fidelity'
    }
  }
}

function Get-TradeData {
  Param (
    [Parameter(Mandatory=$True,Position=0)]
      [String]$DataFile,
    [Parameter(Mandatory=$True,Position=1)]
      [String]$FileType
  )
  switch ($FileType) {
    'Tastyworks' {
      Import-Csv $DataFile | Where-Object { $_.Type -eq 'Trade' }
    }
    'Fidelity' {
      $Reader = New-Object System.IO.StreamReader($DataFile)
      # Fidelity "CSV" files have four lines of 
      # crap before the actual csv data begins
      # We also have to define the header below
      for($i = 0; $i -lt 5; $i++) {
        $garbage = $Reader.ReadLine()
      }
      Remove-Variable -Name garbage
      do
      {
        $line = $Reader.ReadLine()
        if ($line.Length) {
          $data = $data + "`n" + $line
        }
      } while ($line.Length)
      $Header = 'Run Date', 'Account', 'Action', 'Symbol', 'Security Description',
        'Security Type', 'Exchange Quality', 'Exchange Currency', 'Quantity',
        'Currency', 'Price', 'Exchange Rate', 'Commission', 'Fees', 'Accrued Interest',
        'Amount', 'Settlement Date'
      $data | ConvertFrom-Csv -Header $Header
    }
  }
}

function Get-TradeStats {
  param (
    [Parameter(Mandatory=$True,Position=0)]
      [PSObject]$TradeData,
    [Parameter(Mandatory=$True,Position=1)]
      [String]$DataType
  )
  $tradeStats = '' | Select-Object 'Premium Sold', 'Premium Paid', 'Fees', `
    'Commissions', 'Profit / Loss', 'Premium Capture Rate', 'Trades', `
    'Long Calls Opened', 'Long Calls Closed', 'Long Puts Opened', `
    'Long Puts Closed', 'Short Calls Opened', 'Short Calls Closed', `
    'Short Puts Opened', 'Short Puts Closed', 'Short Call Win Rate', `
    'Short Put Win Rate'
  $tradeStats.'Long Calls Opened' = $tradeStats.'Long Calls Closed' `
    = $tradeStats.'Long Puts Opened' = $tradeStats.'Long Puts Closed' `
    = $tradeStats.'Short Calls Opened' = $tradeStats.'Short Calls Closed' `
    = $tradeStats.'Short Puts Opened' = $tradeStats.'Short Puts Closed' = 0
  switch ($DataType) {
    'Tastyworks' {
      $TradeData | ForEach-Object { $row = $_
        switch ($row.Action) {
          'BUY_TO_OPEN' { 
            $tradeStats.'Premium Paid' += [Math]::Abs($row.Value) 
            $tradeStats.'Fees' += [Math]::Abs($row.Fees)
            $tradeStats.'Commissions' += [Math]::Abs($row.Commissions)
            $tradeStats.Trades += 1
            if ($row.'Call or Put' -eq 'Call') {
              $tradeStats.'Long Calls Opened' += 1
            } elseif ($row.'Call or Put' -eq 'Put') {
              $tradeStats.'Long Puts Opened' += 1
            }
          }
          'BUY_TO_CLOSE' { 
            $tradeStats.'Premium Paid' += [Math]::Abs($row.Value) 
            $tradeStats.'Fees' += [Math]::Abs($row.Fees)
            $tradeStats.Trades += 1
            if ($row.'Call or Put' -eq 'Call') {
              $tradeStats.'Short Calls Closed' += 1
            } elseif ($row.'Call or Put' -eq 'Put') {
              $tradeStats.'Short Puts Closed' += 1
            }
          }
          'SELL_TO_OPEN' { 
            $tradeStats.'Premium Sold' += [Math]::Abs($row.Value) 
            $tradeStats.'Fees' += [Math]::Abs($row.Fees)
            $tradeStats.'Commissions' += [Math]::Abs($row.Commissions)
            $tradeStats.Trades += 1
            if ($row.'Call or Put' -eq 'Call') {
              $tradeStats.'Short Calls Opened' += 1
            } elseif ($row.'Call or Put' -eq 'Put') {
              $tradeStats.'Short Puts Opened' += 1
            }
          }
          'SELL_TO_CLOSE' { 
            $tradeStats.'Premium Sold' += [Math]::Abs($row.Value) 
            $tradeStats.'Fees' += [Math]::Abs($row.Fees)
            $tradeStats.Trades += 1
            if ($row.'Call or Put' -eq 'Call') {
              $tradeStats.'Long Calls Closed' += 1
            } elseif ($row.'Call or Put' -eq 'Put') {
              $tradeStats.'Long Puts Closed' += 1
            }
          }
        }
      }
    }
    'Fidelity' {
      $TradeData | ForEach-Object { $row = $_
        switch -Wildcard ($row.Action) {
          'YOU BOUGHT OPENING*' {
            $tradeStats.'Premium Paid' += [Math]::Round([Int]$row.Quantity * 100 * [Decimal]$row.Price, 2)
            $tradeStats.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $tradeStats.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
            $tradeStats.Trades += 1
            if ($row.'Security Description' -match 'CALL\s.*') {
              $tradeStats.'Long Calls Opened' += 1
            } elseif ($row.'Security Description' -match 'PUT\s.*') {
              $tradeStats.'Long Puts Opened' += 1
            }
          }
          'YOU BOUGHT CLOSING*' {
            $tradeStats.'Premium Paid' += [Math]::Round([Int]$row.Quantity * 100 * [Decimal]$row.Price, 2)
            $tradeStats.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $tradeStats.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
            $tradeStats.Trades += 1
            if ($row.'Security Description' -match 'CALL\s.*') {
              $tradeStats.'Short Calls Closed' += 1
            } elseif ($row.'Security Description' -match 'PUT\s.*') {
              $tradeStats.'Short Puts Closed' += 1
            }
          }
          'YOU SOLD OPENING*' {
            $tradeStats.'Premium Sold' += [Math]::Round([Math]::Abs($row.Quantity) * 100 * [Decimal]$row.Price, 2)
            $tradeStats.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $tradeStats.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
            $tradeStats.Trades += 1
            if ($row.'Security Description' -match 'CALL\s.*') {
              $tradeStats.'Short Calls Opened' += 1
            } elseif ($row.'Security Description' -match 'PUT\s.*') {
              $tradeStats.'Short Puts Opened' += 1
            }
          }
          'YOU SOLD CLOSING*' {
            $tradeStats.'Premium Sold' += [Math]::Round([Math]::Abs($row.Quantity) * 100 * [Decimal]$row.Price, 2)
            $tradeStats.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $tradeStats.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
            $tradeStats.Trades += 1
            if ($row.'Security Description' -match 'CALL\s.*') {
              $tradeStats.'Long Calls Closed' += 1
            } elseif ($row.'Security Description' -match 'PUT\s.*') {
              $tradeStats.'Long Puts Closed' += 1
            }
          }
        }
      }    
    }
  }
  $tradeStats.Fees = [Math]::Round($tradeStats.Fees, 2)
  $tradeStats.'Profit / Loss' = `
    [Math]::Round(
      (($tradeStats.'Premium Sold' - $tradeStats.'Premium Paid') `
        - ($tradeStats.Fees + $tradeStats.Commissions)), 2)
  $tradeStats.'Premium Capture Rate' = `
    [Math]::Round(
      ((($tradeStats.'Premium Sold' - $tradeStats.'Premium Paid') `
        - ($tradeStats.Fees + $tradeStats.Commissions)) `
        / $tradeStats.'Premium Sold'), 4)
  if ($tradeStats.'Short Calls Closed') {
    $tradeStats.'Short Call Win Rate' = `
      [Math]::Round($tradeStats.'Short Calls Closed' / $tradeStats.'Short Calls Opened', 4)
  } else { $tradeStats.'Short Call Win Rate' = 1 }
  if ($tradeStats.'Short Puts Closed') {
    $tradeStats.'Short Put Win Rate' = `
      [Math]::Round($tradeStats.'Short Puts Closed' / $tradeStats.'Short Puts Opened', 4)
  } else { $tradeStats.'Short Put Win Rate' = 1 }
  $tradeStats
}

if (Test-Path -Path $InputFile)
{
  $InputFile = Resolve-Path -Path $InputFile
  if (!$FileType) {
    $FileType = Get-FileType -InputFile $InputFile
  }
  $TradeData = Get-TradeData -DataFile $InputFile -FileType $FileType
} else {
  Write-Output ("InputFile '{0}' not found." -f $InputFile)
}

$tradeStats = Get-TradeStats -TradeData $TradeData -DataType $FileType

if ($ObjectOut) {
  $tradeStats
} else {
  "`n        Premium Sold: {0,15:C}" -f $tradeStats.'Premium Sold'
  "        Premium Paid: {0,15:C}" -f $tradeStats.'Premium Paid'
  "                Fees: {0,15:C}" -f $tradeStats.Fees
  "         Commissions: {0,15:C}" -f $tradeStats.Commissions
  "       Profit / Loss: {0,15:C}" -f $tradeStats.'Profit / Loss'
  "Premium Capture Rate: {0,15:P2}" -f $tradeStats.'Premium Capture Rate'
  "              Trades: {0,15}" -f $tradeStats.Trades
  if ($details) {
    "   Long Calls Opened: {0,15}" -f $tradeStats.'Long Calls Opened'
    "   Long Calls Closed: {0,15}" -f $tradeStats.'Long Calls Closed'
    "  Short Calls Opened: {0,15}" -f $tradeStats.'Short Calls Opened'
    "  Short Calls Closed: {0,15}" -f $tradeStats.'Short Calls Closed'
    "    Long Puts Opened: {0,15}" -f $tradeStats.'Long Puts Opened'
    "    Long Puts Closed: {0,15}" -f $tradeStats.'Long Puts Closed'
    "   Short Puts Opened: {0,15}" -f $tradeStats.'Short Puts Opened'
    "   Short Puts Closed: {0,15}" -f $tradeStats.'Short Puts Closed'
  }
  " Short Call Win Rate: {0,15:P2}" -f $tradeStats.'Short Call Win Rate'
  "  Short Put Win Rate: {0,15:P2}`n" -f $tradeStats.'Short Put Win Rate'

}
