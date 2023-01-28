BeforeAll {
  . src/Get-PremiumStats.ps1
}

Describe 'Get-TradeData' {
  It 'returns Tastyworks trade data from the csv as objects' {
    $Reference = [PSCustomObject]@{
      'Action' = 'BUY_TO_CLOSE'
      'Average Price' = '-10.00'
      'Call or Put' = 'PUT'
      'Commissions' = '0.00'
      'Date' = '2023-01-13T14:20:22-0600'
      'Description' = 'Bought 1 SPX 01/13/23 Put 3965.00 @ 0.10'
      'Expiration Date' = '1/13/23'
      'Fees' = '-0.77'
      'Instrument Type' = 'Equity Option'
      'Multiplier' = '100'
      'Order #' = '250516029'
      'Quantity' = '1'
      'Root Symbol' = 'SPXW'
      'Strike Price' = '3965.0'
      'Symbol' = 'SPXW 230113P03965000'
      'Type' = 'Trade'
      'Underlying Symbol' = 'SPX'
      'Value' = '-10.00'
    }
    $TradeData = Get-TradeData -FileType 'Tastyworks' -DataFile './tests/tastyworks_sample.csv' | Select-Object -First 1
    Compare-Object -PassThru -IncludeEqual $Reference $TradeData | Select-Object -ExpandProperty SideIndicator | Should -Be '=='
  }

  It 'returns Fidelity trade data from the csv as objects' {
    $Reference = [PSCustomObject]@{
      'Run Date' = '01/09/2023'
      'Account' = 'Sample Account'
      'Action' = 'YOU BOUGHT CLOSING TRANSACTION PUT (URNM) SPROTT FDS TR FEB 17 23 $31 (100 SHS) (Cash)'
      'Symbol' = '-URNM230217P31'
      'Security Description' = 'PUT (URNM) SPROTT FDS TR FEB 17 23 $31 (100 SHS)'
      'Security Type' = 'Cash'
      'Exchange Quality' = '0'
      'Exchange Currency' = ''
      'Quantity' = '1'
      'Currency' = 'USD'
      'Price' = '0.65'
      'Exchange Rate' = '0'
      'Commission' = '' 
      'Fees' = '0.02'
      'Accrued Interest' = '' 
      'Amount' = '-65.02'
      'Settlement Date' = '01/10/2023'
    }
    $TradeData = Get-TradeData -FileType 'Fidelity' -DataFile './tests/Fidelity_Sample.csv' | Select-Object -First 1
    Compare-Object -PassThru -IncludeEqual $Reference $TradeData | Select-Object -ExpandProperty SideIndicator | Should -Be '=='
  }
}

Describe 'Tastyworks trade data calculations' {
  BeforeAll {
    $obj = Get-TradeStats -DataType 'Tastyworks' -TradeData (Get-TradeData -FileType 'Tastyworks' $InputFile)
  }

  It 'correctly calculates Premium Sold' {
    $obj.'Premium Sold' | Should -Be 3095
  }

  It 'correctly calculates Premium Paid' {
    $obj.'Premium Paid' | Should -Be 2365
  }

  It 'correctly calculates Fees' {
    $obj.Fees | Should -Be 50.88
  }

  It 'correctly calculates Commissions' {
    $obj.Commissions | Should -Be 38
  }

  It 'correctly calculates Profit / Loss' {
    $obj.'Profit / Loss' | Should -Be 641.12
  }

  It 'correctly calculates Premium Capture Rate' {
    $obj.'Premium Capture Rate' | Should -Be .2071
  }
  
  It 'correctly calculates the number of trades' {
    $obj.Trades | Should -Be 63
  }
  
  It 'correctly calculates the number of long calls opened' {
    $obj.'Long Calls Opened' | Should -Be 6
  }

  It 'correctly calculates the number of long calls closed' {
    $obj.'Long Calls Closed' | Should -Be 1
  }

  It 'correctly calculates the number of short calls opened' {
    $obj.'Short Calls Opened' | Should -Be 12
  }

  It 'correctly calculates the number of short calls closed' {
    $obj.'Short Calls Closed' | Should -Be 12
  }

  It 'correctly calculates the number of long puts opened' {
    $obj.'Long Puts Opened' | Should -Be 5
  }

  It 'correctly calculates the number of long puts closed' {
    $obj.'Long Puts Closed' | Should -Be 0
  }

  It 'correctly calculates the number of short puts opened' {
    $obj.'Short Puts Opened' | Should -Be 14
  }

  It 'correctly calculates the number of short puts closed' {
    $obj.'Short Puts Closed' | Should -Be 13
  }

  It 'correctly calculates the short call win rate' {
    $obj.'Short Call Win Rate' | Should -Be 0
  }

  It 'correctly calculates the short put win rate' {
    $obj.'Short Put Win Rate' | Should -Be 0.0714
  }
}

Describe 'Fidelity trade data calculations' {
  BeforeAll {
    $obj = Get-TradeStats -DataType 'Fidelity' -TradeData (Get-TradeData -FileType 'Fidelity' './tests/Fidelity_Sample.csv')
  }

  It 'correctly calculates Premium Sold' {
    $obj.'Premium Sold' | Should -Be 3472
  }

  It 'correctly calculates Premium Paid' {
    $obj.'Premium Paid' | Should -Be 3162
  }

  It 'correctly calculates Fees' {
    $obj.Fees | Should -Be 1.74
  }

  It 'correctly calculates Commissions' {
    $obj.Commissions | Should -Be 28.95
  }

  It 'correctly calculates Profit / Loss' {
    $obj.'Profit / Loss' | Should -Be 279.31
  }

  It 'correctly calculates Premium Capture Rate' {
    $obj.'Premium Capture Rate' | Should -Be .0804
  }

  It 'correctly calculates the number of trades' {
    $obj.Trades | Should -Be 61
  }

  It 'correctly calculates the number of long calls opened' {
    $obj.'Long Calls Opened' | Should -Be 2
  }

  It 'correctly calculates the number of long calls closed' {
    $obj.'Long Calls Closed' | Should -Be 2
  }

  It 'correctly calculates the number of short calls opened' {
    $obj.'Short Calls Opened' | Should -Be 3
  }

  It 'correctly calculates the number of short calls closed' {
    $obj.'Short Calls Closed' | Should -Be 4
  }

  It 'correctly calculates the number of long puts opened' {
    $obj.'Long Puts Opened' | Should -Be 4
  }

  It 'correctly calculates the number of long puts closed' {
    $obj.'Long Puts Closed' | Should -Be 4
  }

  It 'correctly calculates the number of short puts opened' {
    $obj.'Short Puts Opened' | Should -Be 20
  }

  It 'correctly calculates the number of short puts closed' {
    $obj.'Short Puts Closed' | Should -Be 22
  }

  It 'correctly calculates the short call win rate' {
    $obj.'Short Call Win Rate' | Should -Be -0.3333
  }

  It 'correctly calculates the short put win rate' {
    $obj.'Short Put Win Rate' | Should -Be -0.1
  }
}

Describe 'Get-FileType' {
  It 'correctly identifies Tastyworks file type' {
    Get-FileType './tests/tastyworks_sample.csv' | Should -Be 'Tastyworks'
  }

  It 'correctly identifies Fidelity file type' {
    Get-FileType './tests/Fidelity_Sample.csv' | Should -Be 'Fidelity'
  }
}
