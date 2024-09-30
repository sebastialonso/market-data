require "test_helper"
require 'market_data/mappers'
require 'market_data/constants'

module MarketData
  class TestMappers < Minitest::Test
    include MarketData::Mappers

    def test_map_quote_returns_as_expected
      input = {
        "s" => "ok",
        "symbol" => ["AAPL"],
        "ask" => [149.08],
        "askSize" => [200],
        "bid" => [149.07],
        "bidSize" => [600],
        "mid" => [149.07],
        "last" => [149.09],
        "volume" => [66959442],
        "change" => [1.0428],
        "changepct" => [0.0046],
        "updated" => [1663958092]
      }
      
      expected = map_quote input
      excluded = [:high52, :low52]
      Constants::QUOTE_FIELDS.reject{ |x| excluded.include?(x) }.each do |field|
        assert_equal input[field.to_s][0], expected[field]
      end  
    end

    def test_map_bulk_quotes_returns_as_expected
      input = {
        "s" => "ok",
        "symbol" => ["AAPL", "META", "MSFT"],
        "ask" => [187.67, 396.9, 407.0],
        "askSize" => [1, 6, 1],
        "bid" => [187.65, 396.8, 406.97],
        "bidSize" => [1, 3, 3],
        "mid" => [187.66, 396.85, 406.985],
        "last" => [187.65, 396.85, 407.0],
        "change" => [-4.079999999999984, -4.169999999999959, -2.7200000000000273],
        "changepct" => [-0.021279924894382643, -0.010398483866141239, -0.006638680074197078],
        "volume" => [55299411, 18344385, 29269513],
        "updated" => [1706650085, 1706650085, 1706650085]
      }

      excluded = [:high52, :low52]
      expected_hash = map_bulk_quotes input
      
      assert_equal input["symbol"].size, expected_hash.size
      input["symbol"].each_with_index do |k, i|
        refute_nil expected_hash[k]
        assert_equal k, expected_hash[k]["symbol"]
        excluded.each do |field|
          assert_nil expected_hash[k][field]  
        end
        # check all fields except excluded
        Constants::QUOTE_FIELDS.reject{ |x| excluded.include?(x) }.each do |field|
          assert_equal input[field.to_s][i], expected_hash[k][field]
        end  
        
      end
    end
  end
end