require "test_helper"
require 'market_data/options'

module MarketData
  class TestOptions < Minitest::Test
    AAPL_QUOTE = "AAPL"
    
    # Test double
    class UsingOptions
      include MarketData::Options
    end

    def setup
      @s = UsingOptions.new
    end

    def test_expirations_raises_when_invalid_query
      @s.expects(:validate_expirations_input!).raises(BadParameterError)
      assert_raises(BadParameterError) { @s.expirations(AAPL_QUOTE) }
    end

    def test_expirations_runs_as_expected
      @s.expects(:do_connect)
        .with("https://api.marketdata.app/v1/options/expirations/#{AAPL_QUOTE}/")
        .returns(TestData::STUB_EXPIRATIONS_RESPONSE)
      
        actual = @s.expirations(AAPL_QUOTE)
        assert_kind_of Models::OptExpirations, actual 
    end
  end
end