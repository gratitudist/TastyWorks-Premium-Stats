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
    $TradeData = Get-TradeData $InputFile
  }

  It 'returns a sum of premium collected' {
    Get-Premium $TradeData 'Collected' | Should -Be 3065
  }

  It 'returns a sum of premium paid' {
    Get-Premium $TradeData 'Paid' | Should -Be 2280
  }

  Context 'Get-PremiumStats' {
    BeforeAll {
      $Collected = Get-Premium $TradeData 'Collected'
      $Paid = Get-Premium $TradeData 'Paid'
    }

    It 'returns the premium capture rate' {
      Get-PremiumStat $Collected $Paid 'PCR' | Should -Be 25.61
    }

    It 'returns the profit and loss' {
      Get-PremiumStat $Collected $Paid 'PL' | Should -Be 785
    }
  }
}
