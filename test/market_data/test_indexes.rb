require 'market_data/indexes' # TODO remove

module MarketData
  class TestIndexes < Minitest::Test
    VIX_INDEX = "VIX"
    STUB_VALIDATION_RETURNS = {}
    STUB_DO_REQUEST_RETURNS = {}
    STUB_INDEX_QUOTE = Models::IndexQuote.new(
      symbol: VIX_INDEX, high52: 10, low52: 9
    )
    STUB_INDEX_CANDLE = Models::IndexCandle.new(
      symbol: VIX_INDEX, open: 10, close: 9, time: Time.now.to_i
    )

    class UsingIndexes
      include MarketData::Indexes
    end
    
    def setup
      @s = UsingIndexes.new  
    end

    def test_quote_runs_as_expected
      opts = { w52: true }
      query = {"52week" => opts[:w52]}
      
      @s.expects(:validate_index_quote_input!).returns(query)
      @s.expects(:do_request).
        with(Indexes.class_variable_get(:@@quotes) + VIX_INDEX, query).
        returns(STUB_DO_REQUEST_RETURNS)
      @s.expects(:map_index_quote).with(STUB_DO_REQUEST_RETURNS).returns(STUB_INDEX_QUOTE)
      
      actual = @s.index_quote(VIX_INDEX, opts)

      assert_kind_of Models::IndexQuote, actual
      assert_equal STUB_INDEX_QUOTE.symbol, actual[:symbol]
      assert_equal STUB_INDEX_QUOTE.high52, actual[:high52]
      assert_equal STUB_INDEX_QUOTE.low52, actual[:low52]
    end

    def test_index_candles_raises_when_arguments_invalid
      @s.expects(:validate_index_candles_input!).raises(BadParameterError)
      assert_raises(BadParameterError) { @s.index_candles(VIX_INDEX) }
    end

    def test_index_candles_raises_returns_as_expected
      opts = {
        resolution: "D"
      }
      @s.expects(:validate_index_candles_input!).returns(STUB_VALIDATION_RETURNS)
      @s.expects(:do_request).
        with(Indexes.class_variable_get(:@@candles) + opts[:resolution] + "/" + VIX_INDEX, STUB_VALIDATION_RETURNS).
        returns(STUB_DO_REQUEST_RETURNS)
        @s.expects(:map_index_candles).with(STUB_DO_REQUEST_RETURNS, VIX_INDEX).returns(STUB_INDEX_CANDLE)

      actual = @s.index_candles(VIX_INDEX, **{resolution: "D"})
      assert_kind_of Models::IndexCandle, actual
    end
  end
end