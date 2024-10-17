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
end