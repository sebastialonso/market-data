require "test_helper"
require 'market_data/mappers'
require 'market_data/constants'
require 'market_data/models' # TODO remove

module MarketData
  class TestMappers < Minitest::Test
    include MarketData::Mappers
    include MarketData::Models

    AAPL_QUOTE = "AAPL"

    def test_map_quote_returns_as_expected
      input = TestData::STUB_QUOTE_RESPONSE
      
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
    
    def test_map_candles
      input = TestData::STUB_CANDLES_RESPONSE
      actual = map_candles input, AAPL_QUOTE
      assert_kind_of Array, actual
      assert_equal 1, actual.size
      assert_kind_of Models::Candle, actual[0]
    end

    def test_map_bulk_candles
      input = TestData::STUB_BULK_CANDLES_RESPONSE
      actual = map_bulk_candles input
      assert_kind_of Hash, actual
      assert_equal 2, actual.size
      assert_kind_of Models::Candle, actual.fetch(AAPL_QUOTE)
    end

    def test_map_earnings
      input = TestData::STUB_EARNINGS_RESPONSE
      actual = map_earnings input
      assert_kind_of Array, actual
      assert_equal 1, actual.size
      assert_kind_of Models::Earning, actual[0]
    end

    def test_map_index_quote
      input = TestData::STUB_INDEX_QUOTE_RESPONSE
      actual = map_index_quote input
      assert_kind_of Models::IndexQuote, actual
    end

    def test_map_index_candles
      input = TestData::STUB_INDEX_CANDLES_RESPONSE  
      actual = map_index_candles input, AAPL_QUOTE
      assert_kind_of Array, actual
      assert_equal 1, actual.size
      assert_kind_of Models::IndexCandle, actual[0]
    end

    def test_map_expirations
      input = TestData::STUB_EXPIRATIONS_RESPONSE
      actual = map_expirations input
      assert_kind_of Models::OptExpirations, actual
      assert_equal input["expirations"].size, actual.expirations.size
    end

    def test_map_lookup
      input = {
        "s" => "ok",
        "optionSymbol" => "AAPL230728C00200000"
      }

      actual = map_lookup input
      assert_kind_of String, actual
      assert_equal input["optionSymbol"], actual
    end

    def test_map_strike
      input = TestData::STUB_STRIKE_RESPONSE
      actual = map_strike input
      assert_kind_of Models::OptStrike, actual
      assert input.key? "2024-10-10" 
      assert actual.strikes.key? "2024-10-10" 
    end
    
    def test_map_option_chain
      input = TestData::STUB_CHAIN_RESPONSE
      actual = map_option_chain input
      assert_kind_of Array, actual
      assert_kind_of Models::OptChain, actual[0]
      assert_equal "AAPL", actual[0][:underlying]
    end

    def test_map_option_quote
      input = TestData::STUB_OPTION_QUOTES_RESPONSE
      actual = map_option_quote input
      assert_kind_of Models::OptQuote, actual
      assert actual[:option_symbol].include? "AAPL"
    end

    def test_map_fields_for_raises_when_unkown_kind
      assert_raises(BadParameterError) { map_fields_for({}, :invalid) }
    end
    
    def test_map_fields_for_earnings
      response = TestData::STUB_EARNINGS_RESPONSE
      actual = map_fields_for response, :earning
      assert_equal response["fiscalYear"][0], actual[:fiscal_year]
      assert_equal response["fiscalQuarter"][0], actual[:fiscal_quarter]
      assert_equal response["reportedEPS"][0], actual[:reported_eps]
    end

    def test_map_fields_for_candles
      response = TestData::STUB_CANDLES_RESPONSE
      actual = map_fields_for response, :candle
      assert_equal response["symbol"][0], actual[:symbol]
      assert_equal response["o"][0], actual[:open]
      assert_equal response["h"][0], actual[:high]
      assert_equal response["l"][0], actual[:low]
      assert_equal response["c"][0], actual[:close]
      assert_equal response["v"][0], actual[:volume]
      assert_equal response["t"][0], actual[:time]
    end

    def test_map_fields_for_quotes
      response = TestData::STUB_QUOTE_RESPONSE
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
      assert_equal response["52weekHigh"][0], actual[:high52]
      assert_equal response["52weekLow"][0], actual[:low52]
    end
    
    def test_map_fields_for_index_quotes
      response = TestData::STUB_INDEX_QUOTE_RESPONSE
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
      response = TestData::STUB_INDEX_CANDLES_RESPONSE
      actual = map_fields_for response, :index_candle
      assert_equal response["o"][0], actual[:open]
      assert_equal response["h"][0], actual[:high]
      assert_equal response["l"][0], actual[:low]
      assert_equal response["c"][0], actual[:close]
      assert_equal response["t"][0], actual[:time]
    end

    def test_map_fields_for_option_chain
      response = TestData::STUB_CHAIN_RESPONSE
      actual = map_fields_for response, :option_chain

      Constants::OPTION_CHAIN_FIELD_MAPPING.each do |field_sym, field_raw|
        assert_equal response[field_raw][0], actual[field_sym]
      end
    end

    def test_map_fields_for_option_quote
      response = TestData::STUB_OPTION_QUOTES_RESPONSE
      actual = map_fields_for response, :option_quote

      Constants::OPTION_QUOTE_FIELD_MAPPING.each do |field_sym, field_raw|
        assert_equal response[field_raw][0], actual[field_sym]
      end
    end
  end
end