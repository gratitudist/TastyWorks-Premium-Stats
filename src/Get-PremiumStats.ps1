[CmdletBinding()]
Param
(
  [Parameter(Mandatory=$False,Position=0)]
    [String]$InputFile='tests/tastyworks_sample.csv',
  [Parameter(Mandatory=$False,Position=1)]
    [Switch]$ObjectOut=$False,
  [Parameter(Mandatory=$False,Position=2)]
    [String]$FileType
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
  $obj = '' | Select-Object 'Premium Sold', 'Premium Paid', 'Fees', 'Commissions', 'Profit / Loss', 'Premium Capture Rate', 'Trades', 'Long Calls Opened', 'Long Calls Closed', 'Long Puts Opened', 'Long Puts Closed', 'Short Calls Opened', 'Short Calls Closed', 'Short Puts Opened', 'Short Puts Closed'
  $obj.'Long Calls Opened' = $obj.'Long Calls Closed' = $obj.'Long Puts Opened' = $obj.'Long Puts Closed' = $obj.'Short Calls Opened' = $obj.'Short Calls Closed' = $obj.'Short Puts Opened' = $obj.'Short Puts Closed' = 0
  switch ($DataType) {
    'Tastyworks' {
      $TradeData | ForEach-Object { $row = $_
        switch ($row.Action) {
          'BUY_TO_OPEN' { 
            $obj.'Premium Paid' += [Math]::Abs($row.Value) 
            $obj.'Fees' += [Math]::Abs($row.Fees)
            $obj.'Commissions' += [Math]::Abs($row.Commissions)
            $obj.Trades += 1
            if ($row.'Call or Put' -eq 'Call') {
              $obj.'Long Calls Opened' += 1
            } elseif ($row.'Call or Put' -eq 'Put') {
              $obj.'Long Puts Opened' += 1
            }
          }
          'BUY_TO_CLOSE' { 
            $obj.'Premium Paid' += [Math]::Abs($row.Value) 
            $obj.'Fees' += [Math]::Abs($row.Fees)
            $obj.Trades += 1
            if ($row.'Call or Put' -eq 'Call') {
              $obj.'Short Calls Closed' += 1
            } elseif ($row.'Call or Put' -eq 'Put') {
              $obj.'Short Puts Closed' += 1
            }
          }
          'SELL_TO_OPEN' { 
            $obj.'Premium Sold' += [Math]::Abs($row.Value) 
            $obj.'Fees' += [Math]::Abs($row.Fees)
            $obj.'Commissions' += [Math]::Abs($row.Commissions)
            $obj.Trades += 1
            if ($row.'Call or Put' -eq 'Call') {
              $obj.'Short Calls Opened' += 1
            } elseif ($row.'Call or Put' -eq 'Put') {
              $obj.'Short Puts Opened' += 1
            }
          }
          'SELL_TO_CLOSE' { 
            $obj.'Premium Sold' += [Math]::Abs($row.Value) 
            $obj.'Fees' += [Math]::Abs($row.Fees)
            $obj.Trades += 1
            if ($row.'Call or Put' -eq 'Call') {
              $obj.'Long Calls Closed' += 1
            } elseif ($row.'Call or Put' -eq 'Put') {
              $obj.'Long Puts Closed' += 1
            }
          }
        }
      }
    }
    'Fidelity' {
      $TradeData | ForEach-Object { $row = $_
        switch -Wildcard ($row.Action) {
          'YOU BOUGHT OPENING*' {
            $obj.'Premium Paid' += [Math]::Round([Int]$row.Quantity * 100 * [Decimal]$row.Price, 2)
            $obj.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $obj.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
            $obj.Trades += 1
            if ($row.'Security Description' -match 'CALL\s.*') {
              $obj.'Long Calls Opened' += 1
            } elseif ($row.'Security Description' -match 'PUT\s.*') {
              $obj.'Long Puts Opened' += 1
            }
          }
          'YOU BOUGHT CLOSING*' {
            $obj.'Premium Paid' += [Math]::Round([Int]$row.Quantity * 100 * [Decimal]$row.Price, 2)
            $obj.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $obj.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
            $obj.Trades += 1
            if ($row.'Security Description' -match 'CALL\s.*') {
              $obj.'Short Calls Closed' += 1
            } elseif ($row.'Security Description' -match 'PUT\s.*') {
              $obj.'Short Puts Closed' += 1
            }
          }
          'YOU SOLD OPENING*' {
            $obj.'Premium Sold' += [Math]::Round([Math]::Abs($row.Quantity) * 100 * [Decimal]$row.Price, 2)
            $obj.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $obj.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
            $obj.Trades += 1
            if ($row.'Security Description' -match 'CALL\s.*') {
              $obj.'Short Calls Opened' += 1
            } elseif ($row.'Security Description' -match 'PUT\s.*') {
              $obj.'Short Puts Opened' += 1
            }
          }
          'YOU SOLD CLOSING*' {
            $obj.'Premium Sold' += [Math]::Round([Math]::Abs($row.Quantity) * 100 * [Decimal]$row.Price, 2)
            $obj.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $obj.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
            $obj.Trades += 1
            if ($row.'Security Description' -match 'CALL\s.*') {
              $obj.'Long Calls Closed' += 1
            } elseif ($row.'Security Description' -match 'PUT\s.*') {
              $obj.'Long Puts Closed' += 1
            }
          }
        }
      }    
    }
  }
  $obj.Fees = [Math]::Round($obj.Fees, 2)
  $obj.'Profit / Loss' = [Math]::Round((($obj.'Premium Sold' - $obj.'Premium Paid') - ($obj.Fees + $obj.Commissions)), 2)
  $obj.'Premium Capture Rate' = [Math]::Round(((($obj.'Premium Sold' - $obj.'Premium Paid') - ($obj.Fees + $obj.Commissions)) / $obj.'Premium Sold'), 4)
  $obj
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

$obj = Get-TradeStats -TradeData $TradeData -DataType $FileType

if ($ObjectOut) {
  $obj
} else {
  "`n        Premium Sold : {0,15:C}" -f $obj.'Premium Sold'
  "        Premium Paid : {0,15:C}" -f $obj.'Premium Paid'
  "                Fees : {0,15:C}" -f $obj.Fees
  "         Commissions : {0,15:C}" -f $obj.Commissions
  "       Profit / Loss : {0,15:C}" -f $obj.'Profit / Loss'
  "Premium Capture Rate : {0,15:P2}" -f $obj.'Premium Capture Rate'
  "              Trades : {0,15}" -f $obj.Trades
  "   Long Calls Opened : {0,15}" -f $obj.'Long Calls Opened'
  "   Long Calls Closed : {0,15}" -f $obj.'Long Calls Closed'
  "  Short Calls Opened : {0,15}" -f $obj.'Short Calls Opened'
  "  Short Calls Closed : {0,15}" -f $obj.'Short Calls Closed'
  "    Long Puts Opened : {0,15}" -f $obj.'Long Puts Opened'
  "    Long Puts Closed : {0,15}" -f $obj.'Long Puts Closed'
  "   Short Puts Opened : {0,15}" -f $obj.'Short Puts Opened'
  "   Short Puts Closed : {0,15}`n" -f $obj.'Short Puts Closed'

}
