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
      @s.expects(:do_request)
        .with("/v1/options/expirations/#{AAPL_QUOTE}/", {})
        .returns(TestData::STUB_EXPIRATIONS_RESPONSE)
      
        actual = @s.expirations(AAPL_QUOTE)
        assert_kind_of Models::OptExpirations, actual 
    end

    def test_lookup_raises_when_invalid_query
      @s.expects(:validate_lookup_input!).raises(BadParameterError)
      assert_raises(BadParameterError) { @s.lookup({})}
    end

    def test_lookup_runs_as_expected
      args = {symbol: AAPL_QUOTE, expiration: "7/28/23", strike: 200, side: MarketData::Constants::SIDE_CALL}
      @s.expects(:do_request)
        .with("/v1/options/lookup/AAPL%207%2F28%2F23%20200%20Call", {})
        .returns(TestData::STUB_LOOKUP_RESPONSE)

      actual = @s.lookup(args)
      assert_kind_of String, actual
      assert_equal TestData::STUB_LOOKUP_RESPONSE["optionSymbol"], actual
    end

    def test_strikes_raises_when_invalid_query
      @s.expects(:validate_strikes_input!).raises(BadParameterError)

      assert_raises(BadParameterError) { @s.strikes(AAPL_QUOTE, {}) }
    end

    def test_strikes_runs_as_expected
      args = {date: Time.now.iso8601}
      @s.expects(:do_request)
        .with("/v1/options/strikes/AAPL/", {date: args[:date]})
        .returns(TestData::STUB_STRIKE_RESPONSE)
      
      actual = @s.strikes(AAPL_QUOTE, args)
      assert_kind_of Models::OptStrike, actual
    end

    def test_chain_raises_when_invalid_query
      @s.expects(:validate_option_chain_input!).raises(BadParameterError)

      assert_raises(BadParameterError) { @s.chain(AAPL_QUOTE, {}) }
    end

    def test_chain_runs_as_expected
      args = {date: Time.now.iso8601}
      @s.expects(:do_request)
        .with("/v1/options/chain/AAPL/", {date: args[:date]})
        .returns(TestData::STUB_CHAIN_RESPONSE)

      actuals = @s.chain(AAPL_QUOTE, args)
      assert_kind_of Array, actuals
      assert_equal 2, actuals.size
    end
    
    def test_option_quote_raises_when_invalid_query
      @s.expects(:validate_option_quote_input!).raises(BadParameterError)

      assert_raises(BadParameterError) { @s.option_quote(AAPL_QUOTE, {}) }
    end

    def test_option_quote_runs_as_expected
      args = {date: Time.now.iso8601}
      @s.expects(:do_request)
        .with("/v1/options/quotes/#{AAPL_QUOTE}/", {date: args[:date]})
        .returns(TestData::STUB_OPTION_QUOTES_RESPONSE)

      actual = @s.option_quote(AAPL_QUOTE, args)
      assert_kind_of Models::OptQuote, actual
    end
  end
end