require "test_helper"
require 'market_data/markets' # TODO remove

module MarketData
  class TestMarkets < Minitest::Test
    
    STUB_GET_URI_RETURNS = "dummy"
    STUB_DO_CONNECT_RETURNS = {}
    STUB_MAP_MARKET_STATUS = MarketData::Models::MarketStatus.new()
    class UsingMarkets
      include MarketData::Markets
    end

    def setup
      @s = UsingMarkets.new
    end

    def test_market_status_raises_when_input_is_invalid
      @s.expects(:validate_market_status_input!).raises(BadParameterError)

      assert_raises(BadParameterError) { @s.market_status()}
    end

    def test_market_status_returns_as_expected
      query = {country: "US", date: Time.now.iso8601}
      expected_path_hash = {
        host: MarketData.base_host,
        path: MarketData::Markets.class_variable_get(:@@status),
        query: URI.encode_www_form(query)
      }
      
      @s.expects(:validate_market_status_input!).returns(query)
      @s.expects(:get_uri).with(expected_path_hash).returns(STUB_GET_URI_RETURNS)
      @s.expects(:do_connect).with(STUB_GET_URI_RETURNS).returns(STUB_DO_CONNECT_RETURNS)
      @s.expects(:map_market_status).with(STUB_DO_CONNECT_RETURNS).returns(STUB_MAP_MARKET_STATUS)

      actual = @s.market_status(**query)
      assert_kind_of Models::MarketStatus, actual
    end
  end
end