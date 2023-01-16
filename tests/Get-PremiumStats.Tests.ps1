BeforeAll {
  . src/Get-PremiumStats.ps1
}

Describe 'Get-TradeData' {
  It 'returns the trade data from the csv as objects' {
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
    $TradeData = Get-TradeData $InputFile | Select-Object -First 1
    Compare-Object -PassThru -IncludeEqual $Reference $TradeData | Select-Object -ExpandProperty SideIndicator | Should -Be '=='
  }
}

Describe 'TradeData calculations' {
  BeforeAll {
    $obj = Get-TradeStats -TradeData (Get-TradeData $InputFile)
  }

  It 'correctly calculate Premium Collected' {
    $obj.'Premium Collected' | Should -Be 3095
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
    $obj.'Profit / Loss' | Should -Be 679.12
  }

  It 'correctly calculates Premium Capture Rate' {
    $obj.'Premium Capture Rate' | Should -Be 21.94
  }
}
