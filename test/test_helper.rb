# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter "test/"
  add_group 'lib', 'lib/'
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "market_data"

require "minitest/autorun"
require 'mocha/minitest'

class TestData
  STUB_QUOTE_RESPONSE = {
    "symbol" => ["AAPL"],
    "ask" => [2024],
    "askSize" => ["Q4"],
    "bid" => [1.25],
    "bidSize" => [3.14],
    "mid" => [4e5],
    "last" => [Time.now.to_i],
    "change" => [4.3],
    "changepct" => [0.15],
    "volume" => [5e4],
    "updated" => [Time.now.to_i],
    "52weekHigh" => [232.2],
    "52weekLow" => [221.4],
  }
  STUB_BULK_CANDLES_RESPONSE = {
    "s"=> "ok",
    "symbol"=> ["AAPL", "AMD"],
    "o"=> [196.16, 345.58],
    "h"=> [196.95, 353.6],
    "l"=> [195.89, 345.12],
    "c"=> [196.94, 350.36],
    "v"=> [40714051, 17729362],
    "t"=> [1703048400,1703048400]
  }
  STUB_CANDLES_RESPONSE = {
    "symbol" => ["AAPL"],
    "o" => [2024],
    "h" => ["Q4"],
    "l" => [1.25],
    "c" => [3.14],
    "v" => [4e5],
    "t" => [Time.now.to_i]
  }
  STUB_EARNINGS_RESPONSE = {
    "s" => "ok",
    "symbol"=> ["AAPL"],
    "fiscalYear"=> [2023],
    "fiscalQuarter"=> [1],
    "date"=> [1672462800],
    "reportDate"=> [1675314000],
    "reportTime"=> ["before market open"],
    "currency"=> ["USD"],
    "reportedEPS"=> [1.88],
    "estimatedEPS"=> [1.94],
    "surpriseEPS"=> [-0.06],
    "surpriseEPSpct"=> [-3.0928],
    "updated"=> [1701690000]
  }
  STUB_MARKET_STATUS_RESPONSE = {
    "s" => "ok",
    "date" => ["2024-10-11"],
    "status" => ["open"]
  }
  STUB_INDEX_QUOTE_RESPONSE = {
    "symbol" => ["VIX"],
    "last" => [Time.now.to_i],
    "change" => [4.3],
    "changepct" => [0.15],
    "updated" => [Time.now.to_i],
    "52weekHigh" => [232.2],
    "52weekLow" => [221.4],
  }
  STUB_INDEX_CANDLES_RESPONSE = {
    "s" => "ok",
    "c" => [22.84],
    "h" => [23.27],
    "l" => [22.26],
    "o" => [22.41],
    "t" => [1659326400]
  }
  STUB_EXPIRATIONS_RESPONSE = {
    "s" => "ok",
    "expirations" => [
      "2022-09-23",
      "2022-09-30",
    ],
    "updated" => 1663704000
  }
  STUB_LOOKUP_RESPONSE = {
    "s" => "ok",
    "optionSymbol" => "AAPL230728C00200000"
  }
  STUB_STRIKE_RESPONSE = {
    "s" => "ok",
    "updated" => 1663704000,
    "2023-01-20" => [
      30.0, 35.0, 40.0, 50.0, 55.0, 60.0
    ],
    "2024-10-10" => [
      30.0, 35.0, 40.0, 50.0, 55.0, 60.0
    ]
  }
  STUB_CHAIN_RESPONSE = {
    "s"=> "ok",
    "optionSymbol"=> ["AAPL230616C00060000", "AAPL230616C00065000"],
    "underlying"=> ["AAPL", "AAPL"],
    "expiration"=> [1686945600, 1686945600],
    "side"=> ["call", "call"],
    "strike"=> [60, 65],
    "firstTraded"=> [1617197400, 1616592600],
    "dte"=> [26, 26],
    "updated"=> [1684702875, 1684702875],
    "bid"=> [114.1, 108.6],
    "bidSize"=> [90, 90],
    "mid"=> [115.5, 110.38],
    "ask"=> [116.9, 112.15],
    "askSize"=> [90, 90],
    "last"=> [115, 107.82],
    "openInterest"=> [21957, 3012],
    "volume"=> [0, 0],
    "inTheMoney"=> [true, true],
    "intrinsicValue"=> [115.13, 110.13],
    "extrinsicValue"=> [0.37, 0.25],
    "underlyingPrice"=> [175.13, 175.13],
    "iv"=> [1.629, 1.923],
    "delta"=> [1, 1],
    "gamma"=> [0, 0],
    "theta"=> [-0.009, -0.009],
    "vega"=> [0, 0],
    "rho"=> [0.046, 0.05]
  }  
  STUB_OPTION_QUOTES_RESPONSE = {
    "s" => "ok",
    "optionSymbol" => ["AAPL250117C00150000"],
    "ask" => [5.25],
    "askSize" => [57],
    "bid" => [5.15],
    "bidSize" => [994],
    "mid" => [5.2],
    "last" => [5.25],
    "volume" => [977],
    "openInterest" => [61289],
    "underlyingPrice" => [136.12],
    "inTheMoney" => [false],
    "updated" => [1665673292],
    "iv" => [0.3468],
    "delta" => [0.347],
    "gamma" => [0.015],
    "theta" => [-0.05],
    "vega" => [0.264],
    "rho" => [0.115],
    "intrinsicValue" => [13.88],
    "extrinsicValue" => [8.68]
  }
end