require "test_helper"

module MarketData
  class TestQuotes < Minitest::Test
    AAPL_QUOTE = "AAPL"
    AMD_QUOTE = "AMD"
    STUB_GET_URI_RETURNS = "dummy"
    STUB_DO_CONNECT_RETURNS = {}
    STUB_MAP_QUOTE_RETURNS = Models::Quote.new(symbol: AAPL_QUOTE)
    STUB_MAP_BULK_QUOTES_RETURNS = {"AAPL" => Models::Quote.new(symbol: AAPL_QUOTE)}
    STUB_MAP_EARNINGS_RETURNS = Models::Earning.new(symbol: AAPL_QUOTE)
    
    def generate_candle_elements how_many
      how_many.times.map do |q|
        STUB_MAP_BULK_QUOTES_RETURNS["AAPL"]
      end
    end

    # Test double
    class UsingQuotes
      include MarketData::Quotes
    end

    def setup
      @q = UsingQuotes.new
    end

    def test_quote_without_parameters_works_as_expected
      expected_path_hash = { host: MarketData.base_host, path: Quotes.class_variable_get(:@@single) + AAPL_QUOTE}
      @q.expects(:validate_quotes_input!).returns({})
      @q.expects(:get_uri).with(expected_path_hash)
      @q.expects(:do_connect).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_quote).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_QUOTE_RETURNS)

      actual = @q.quote(AAPL_QUOTE, false, true)

      assert_equal AAPL_QUOTE, actual.symbol
      assert_kind_of Models::Quote, actual
    end

    def test_quote_with_parameters_works_as_expected
      expected_path_hash = { 
        host: MarketData.base_host, 
        path: Quotes.class_variable_get(:@@single) + AAPL_QUOTE,
        query: URI.encode_www_form({ extended: false, "52week" => true })
      }
      @q.expects(:validate_quotes_input!).returns({extended: false, "52week" => true})
      @q.expects(:get_uri).with(expected_path_hash)
      @q.expects(:do_connect).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_quote).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_QUOTE_RETURNS)

      actual = @q.quote(AAPL_QUOTE, true, false)

      assert_equal AAPL_QUOTE, actual.symbol
      assert_kind_of Models::Quote, actual
    end

    def test_bulk_quotes_raises_when_invalid_input
      symbols = AAPL_QUOTE
      @q.expects(:validate_bulk_quotes_input!).raises(BadParameterError)
      assert_raises(MarketData::BadParameterError) { @q.bulk_quotes(symbols) }
    end

    def test_bulk_quotes_works_as_expected
      expected_path_hash = { 
        host: MarketData.base_host,
        path: Quotes.class_variable_get(:@@bulk),
        query: URI.encode_www_form({ extended: false, symbols: "AAPL,AMD" })
      }

      @q.expects(:get_uri).with(expected_path_hash)
      @q.expects(:do_connect).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_bulk_quotes).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_BULK_QUOTES_RETURNS)
      
      actual = @q.bulk_quotes([AAPL_QUOTE, AMD_QUOTE])
      assert_equal STUB_MAP_BULK_QUOTES_RETURNS, actual
    end

    def test_candles_raises_when_options_are_invalid
      @q.expects(:validate_candles_input!).raises(BadParameterError)
      assert_raises(MarketData::BadParameterError) { @q.candles(AAPL_QUOTE, {}) }
    end

    def test_candles_returns_as_expected
      opts = {
        resolution: "D",
        countback: 2,
        to: Time.now.to_i
      }
      expected_path_hash = { 
        host: MarketData.base_host,
        path: "#{Quotes.class_variable_get(:@@candles)}#{opts[:resolution]}/#{AAPL_QUOTE}",
        query: URI.encode_www_form(opts.except(:resolution))
      }

      @q.expects(:validate_candles_input!).returns(opts.except(:resolution))
      @q.expects(:get_uri).with(expected_path_hash)
      @q.expects(:do_connect).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_candles).with(STUB_DO_CONNECT_RETURNS, AAPL_QUOTE).returns(generate_candle_elements(opts[:countback]))

      actual = @q.candles(AAPL_QUOTE, opts)
      
      assert opts[:countback], actual.size
    end

    def test_bulk_candles_raises_when_arguments_are_invalid
      @q.expects(:validate_bulk_candles_input!).raises(BadParameterError)
      assert_raises(MarketData::BadParameterError) { @q.bulk_candles([]) }
    end

    def test_bulks_candles_returns_as_expected
      opts = {
        resolution: "D",
      }
      expected_path_hash = { 
        host: MarketData.base_host,
        path: "#{Quotes.class_variable_get(:@@bulk_candles)}#{opts[:resolution]}/",
        query: URI.encode_www_form({ symbols: "AAPL,AMD" })
      }

      map_bulk_candles_returns = generate_candle_elements(2)
      @q.expects(:get_uri).with(expected_path_hash)
      @q.expects(:do_connect).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_bulk_candles).with(STUB_DO_CONNECT_RETURNS).returns(map_bulk_candles_returns)

      actual = @q.bulk_candles([AAPL_QUOTE, AMD_QUOTE])

      assert_equal map_bulk_candles_returns, actual
    end

    def test_earnigs_raises_if_validations_fail
      @q.expects(:validate_earnings_input!).raises(BadParameterError)
      assert_raises(MarketData::BadParameterError) { @q.earnings(AAPL_QUOTE, {}) }
    end

    def test_earnings_works_as_expected
      opts = {
        date: "2024-10-11"
      }
      expected_path_hash = { 
        host: MarketData.base_host,
        path: "#{Quotes.class_variable_get(:@@earnings)}#{AAPL_QUOTE}",
        query: URI.encode_www_form({ date: opts[:date] })
      }
      @q.expects(:validate_earnings_input!).returns(opts)
      @q.expects(:get_uri).with(expected_path_hash)
      @q.expects(:do_connect).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_earnings).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_EARNINGS_RETURNS)

      actual = @q.earnings(AAPL_QUOTE, opts)
      assert_equal STUB_MAP_EARNINGS_RETURNS.symbol, actual.symbol
    end
  end
end