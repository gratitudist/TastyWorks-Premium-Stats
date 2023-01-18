[CmdletBinding()]
Param
(
  [Parameter(Mandatory=$False,Position=0)]
    [String]$InputFile='tests/2023-01-01_2023-01-13.csv',
  [Parameter(Mandatory=$False,Position=1)]
    [Switch]$ObjectOut=$False
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
  $obj = 0 | Select-Object 'Premium Collected', 'Premium Paid', 'Fees', 'Commissions', 'Profit / Loss', 'Premium Capture Rate'
  switch ($DataType) {
    'Tastyworks' {
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
    }
    'Fidelity' {
      $TradeData | ForEach-Object { $row = $_
        switch -Wildcard ($row.Action) {
          'YOU BOUGHT OPENING*' {
            $obj.'Premium Paid' += [Math]::Round([Int]$row.Quantity * 100 * [Decimal]$row.Price, 2)
            $obj.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $obj.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
          }
          'YOU BOUGHT CLOSING*' {
            $obj.'Premium Paid' += [Math]::Round([Int]$row.Quantity * 100 * [Decimal]$row.Price, 2)
            $obj.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $obj.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
          }
          'YOU SOLD OPENING*' {
            $obj.'Premium Collected' += [Math]::Round([Math]::Abs($row.Quantity) * 100 * [Decimal]$row.Price, 2)
            $obj.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $obj.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
          }
          'YOU SOLD CLOSING*' {
            $obj.'Premium Collected' += [Math]::Round([Math]::Abs($row.Quantity) * 100 * [Decimal]$row.Price, 2)
            $obj.Fees += [Math]::Round([Decimal]$row.Fees, 2)
            $obj.Commissions += [Math]::Round([Decimal]$row.Commission, 2)
          }
        }
      }    
    }
  }
  $obj.Fees = [Math]::Round($obj.Fees, 2)
  $obj.'Profit / Loss' = [Math]::Round((($obj.'Premium Collected' - $obj.'Premium Paid') - ($obj.Fees + $obj.Commissions)), 2)
  $obj.'Premium Capture Rate' = [Math]::Round(((($obj.'Premium Collected' - $obj.'Premium Paid') - ($obj.Fees + $obj.Commissions)) / $obj.'Premium Collected'), 4)
  $obj
}

if (Test-Path -Path $InputFile)
{
  $FileType = Get-FileType -InputFile $InputFile
  $TradeData = Get-TradeData -DataFile $InputFile -FileType $FileType
} else {
  Write-Output ("InputFile '{0}' not found." -f $InputFile)
}

$obj = Get-TradeStats -TradeData $TradeData -DataType $FileType

if ($ObjectOut) {
  $obj
} else {
  "`n   Premium Collected : {0,15:C}" -f $obj.'Premium Collected'
  "        Premium Paid : {0,15:C}" -f $obj.'Premium Paid'
  "                Fees : {0,15:C}" -f $obj.Fees
  "         Commissions : {0,15:C}" -f $obj.Commissions
  "       Profit / Loss : {0,15:C}" -f $obj.'Profit / Loss'
  "Premium Capture Rate : {0,15:P2}`n" -f $obj.'Premium Capture Rate'
}
