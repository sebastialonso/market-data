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
      
      Constants::QUOTE_FIELD_MAPPING.except(*excluded).each do |field_sym, field_raw|
        assert_equal input[field_raw.to_s][0], expected[field_sym]
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
        Constants::QUOTE_FIELD_MAPPING.except(*excluded).each do |field_sym, field_raw|
          assert_equal input[field_raw][i], expected_hash[k][field_sym]
        end  
      end
    end

    def test_map_fields_for_raises_when_unkown_kind
      assert_raises(BadParameterError) { map_fields_for({}, :invalid) }
    end
    
    def test_map_fields_for_earnings
      response = {
        "fiscalYear" => [2024],
        "fiscalQuarter" => ["Q4"],
        "reportedEPS" => [1.25],
        "not_registered_field" => [3.14]
      }
      actual = map_fields_for response, :earning
      assert_equal response["fiscalYear"][0], actual[:fiscal_year]
      assert_equal response["fiscalQuarter"][0], actual[:fiscal_quarter]
      assert_equal response["reportedEPS"][0], actual[:reported_eps]
      refute actual.key? :not_registered_field
    end

    def test_map_fields_for_candles
      response = {
        "symbol" => ["AAPL"],
        "o" => [2024],
        "h" => ["Q4"],
        "l" => [1.25],
        "c" => [3.14],
        "v" => [4e5],
        "t" => [Time.now.to_i]
      }
      actual = map_fields_for response, :candle
      assert_equal response["symbol"][0], actual[:symbol]
      assert_equal response["o"][0], actual[:open]
      assert_equal response["h"][0], actual[:high]
      assert_equal response["l"][0], actual[:low]
      assert_equal response["c"][0], actual[:close]
      assert_equal response["v"][0], actual[:volume]
      assert_equal response["t"][0], actual[:time]
      refute actual.key? :not_registered_field
    end

    def test_map_fields_for_quotes
      response = {
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
        "high52" => [232.2],
        "low52" => [221.4],
      }

      actual = map_fields_for response, :quote
      assert_equal response["symbol"][0], actual[:symbol]
      assert_equal response["ask"][0], actual[:ask]
      assert_equal response["askSize"][0], actual[:ask_size]
      assert_equal response["bid"][0], actual[:bid]
      assert_equal response["bidSize"][0], actual[:bid_size]
      assert_equal response["mid"][0], actual[:mid]
      assert_equal response["last"][0], actual[:last]
      assert_equal response["change"][0], actual[:change]
      assert_equal response["changepct"][0], actual[:change_pct]
      assert_equal response["volume"][0], actual[:volume]
      assert_equal response["updated"][0], actual[:updated]
      assert_equal response["high52"][0], actual[:high52]
      assert_equal response["low52"][0], actual[:low52]
      refute actual.key? :not_registered_field
    end

    def test_map_market_status
      response = {
        "s" => "ok",
        "date" => ["2024-10-11"],
        "status" => ["open"]
      }

      actual = map_market_status response
      assert_kind_of MarketData::Models::MarketStatus, actual
      assert_equal response["date"][0], actual[:date]
      assert_equal response["status"][0], actual[:status]
    end
    
    def test_map_fields_for_index_quotes
      response = {
        "symbol" => ["VIX"],
        "last" => [Time.now.to_i],
        "change" => [4.3],
        "changepct" => [0.15],
        "updated" => [Time.now.to_i],
        "52weekHigh" => [232.2],
        "52weekLow" => [221.4],
      }

      actual = map_fields_for response, :index_quote
      assert_equal response["symbol"][0], actual[:symbol]
      assert_equal response["last"][0], actual[:last]
      assert_equal response["change"][0], actual[:change]
      assert_equal response["changepct"][0], actual[:change_pct]
      assert_equal response["updated"][0], actual[:updated]
      assert_equal response["52weekHigh"][0], actual[:high52]
      assert_equal response["52weekLow"][0], actual[:low52]
    end

    def test_map_fields_for_index_candles
      response = {
        "symbol" => ["VIX"],
        "o" => [2024],
        "h" => ["Q4"],
        "l" => [1.25],
        "c" => [3.14],
        "t" => [Time.now.to_i]
      }
      actual = map_fields_for response, :index_candle
      assert_equal response["symbol"][0], actual[:symbol]
      assert_equal response["o"][0], actual[:open]
      assert_equal response["h"][0], actual[:high]
      assert_equal response["l"][0], actual[:low]
      assert_equal response["c"][0], actual[:close]
      assert_equal response["t"][0], actual[:time]
    end
  end
end