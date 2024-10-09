require "test_helper"
require 'market_data/mappers'

module MarketData
  class TestQuotes < Minitest::Test
    AAPL_QUOTE = "AAPL"
    STUB_GET_URI_RETURNS = "dummy"
    STUB_DO_CONNECT_RETURNS = {}
    STUB_MAP_QUOTE_RETURNS = Models::Quote.new(symbol: AAPL_QUOTE)
    STUB_MAP_BULK_QUOTES_RETURNS = {"AAPL" => Models::Quote.new(symbol: AAPL_QUOTE)}
    
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

    def test_quote_runs_without_w52
      expected_path_hash = { host: MarketData.base_host, path: Quotes.class_variable_get(:@@single) + AAPL_QUOTE}
      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_quote).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_QUOTE_RETURNS)

      actual = @q.quote(AAPL_QUOTE, false, true)

      assert_equal AAPL_QUOTE, actual.symbol
      assert_kind_of Models::Quote, actual
    end

    def test_quote_runs_with_w52
      STUB_MAP_QUOTE_RETURNS.high52 = 10
      STUB_MAP_QUOTE_RETURNS.low52 = 10
      expected_path_hash = { 
        host: MarketData.base_host, 
        path: Quotes.class_variable_get(:@@single) + AAPL_QUOTE, 
        query: URI.encode_www_form({"52week" => true}) 
      }
      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_quote).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_QUOTE_RETURNS)

      actual = @q.quote(AAPL_QUOTE, true, true)
      assert_equal AAPL_QUOTE, actual.symbol
      assert_kind_of Models::Quote, actual
      refute_nil actual.high52
      refute_nil actual.low52
    end

    def test_quote_runs_with_extended
      expected_path_hash = { 
        host: MarketData.base_host, 
        path: Quotes.class_variable_get(:@@single) + AAPL_QUOTE, 
        query: URI.encode_www_form({"extended" => false}) 
      }

      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_quote).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_QUOTE_RETURNS)

      actual = @q.quote(AAPL_QUOTE, false)
      assert_equal AAPL_QUOTE, actual.symbol
    end

    def test_bulk_quotes_raises_with_no_array_symbols
      symbols = AAPL_QUOTE
      assert_raises(MarketData::BadParameterError) { @q.bulk_quotes(symbols) }
    end
    
    def test_bulk_quotes_raises_with_empty_array_symbols
      symbols = []
      assert_raises(MarketData::BadParameterError) { @q.bulk_quotes(symbols) }
    end

    def test_bulk_quotes_returns_without_snapshot
      expected_path_hash = { 
        host: MarketData.base_host,
        path: Quotes.class_variable_get(:@@bulk),
        query: URI.encode_www_form({ symbols: "AAPL"})
      }

      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_bulk_quotes).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_BULK_QUOTES_RETURNS)

      actual = @q.bulk_quotes([AAPL_QUOTE], snapshot=false, extended = true)
      assert_equal STUB_MAP_BULK_QUOTES_RETURNS, actual
    end

    def test_bulk_quotes_returns_with_snapshot
      expected_path_hash = { 
        host: MarketData.base_host,
        path: Quotes.class_variable_get(:@@bulk),
        query: URI.encode_www_form({ snapshot: true })
      }

      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_bulk_quotes).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_BULK_QUOTES_RETURNS)
      
      actual = @q.bulk_quotes([AAPL_QUOTE], snapshot=true, extended=true)
      assert_equal STUB_MAP_BULK_QUOTES_RETURNS, actual
    end

    def test_bulk_quotes_without_extended
      expected_path_hash = { 
        host: MarketData.base_host,
        path: Quotes.class_variable_get(:@@bulk),
        query: URI.encode_www_form({ extended: false, symbols: "AAPL" })
      }

      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_bulk_quotes).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_BULK_QUOTES_RETURNS)
      
      actual = @q.bulk_quotes([AAPL_QUOTE], snapshot=false, extended=false)
      assert_equal STUB_MAP_BULK_QUOTES_RETURNS, actual
    end

    def test_candles_raises_when_from_and_countback_are_nil
      opts = {
        resolution: "D"
      }
      assert_raises(MarketData::BadParameterError) { @q.candles(AAPL_QUOTE, opts) }
    end

    def test_candles_returns_when_only_countback_is_present
      opts = {
        resolution: "D",
        countback: 2
      }
      expected_path_hash = { 
        host: MarketData.base_host,
        path: "#{Quotes.class_variable_get(:@@candles)}#{opts[:resolution]}/#{AAPL_QUOTE}",
        query: URI.encode_www_form({ to: Time.now.utc.to_i, countback: opts[:countback] })
      }

      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_candles).with(STUB_DO_CONNECT_RETURNS, AAPL_QUOTE).returns(generate_candle_elements(opts[:countback]))

      actual = @q.candles(AAPL_QUOTE, opts)
      
      assert opts[:countback], actual.size
    end

    def test_candles_returns_when_only_from_is_present
      opts = {
        resolution: "D",
        from: Time.now.utc - Constants::DAY
      }
    
      expected_path_hash = { 
        host: MarketData.base_host,
        path: "#{Quotes.class_variable_get(:@@candles)}#{opts[:resolution]}/#{AAPL_QUOTE}",
        query: URI.encode_www_form({ to: Time.now.utc.to_i, from: opts[:from] })
      }

      map_candles_returns = generate_candle_elements(2)
      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_candles).with(STUB_DO_CONNECT_RETURNS, AAPL_QUOTE).returns(map_candles_returns)

      actual = @q.candles(AAPL_QUOTE, opts)
      assert_equal map_candles_returns, actual
    end

    def test_bulk_candles_raises_when_resolution_is_not_allowed
      assert_raises(BadParameterError) { @q.bulk_candles([AAPL_QUOTE], resolution="F") }
    end

    def test_bulk_candles_raises_with_no_array_symbols
      symbols = AAPL_QUOTE
      assert_raises(MarketData::BadParameterError) { @q.bulk_candles(symbols) }
    end
    
    def test_bulk_candles_raises_with_empty_array_symbols
      symbols = []
      assert_raises(MarketData::BadParameterError) { @q.bulk_candles(symbols) }
    end

    def test_bulks_candles_returns_as_expected
      opts = {
        resolution: "D",
        countback: 2
      }
      expected_path_hash = { 
        host: MarketData.base_host,
        path: "#{Quotes.class_variable_get(:@@bulk_candles)}#{opts[:resolution]}/",
        query: URI.encode_www_form({ symbols: "AAPL" })
      }

      map_bulk_candles_returns = generate_candle_elements(opts[:countback])
      @q.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @q.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @q.expects(:map_bulk_candles).with(STUB_DO_CONNECT_RETURNS).returns(map_bulk_candles_returns)

      actual = @q.bulk_candles([AAPL_QUOTE])

      assert_equal map_bulk_candles_returns, actual
    end
  end
end