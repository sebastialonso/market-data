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