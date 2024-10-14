require "test_helper"
require 'ostruct'

module MarketData
  class TestConn < Minitest::Test
    ACCESS_TOKEN = "test"
    API_QUOTE_RAW_RESPONSE = '{
  "s": "ok",
  "symbol": [
    "AAPL"
  ]
}'
    class UsingConn
      include MarketData::Conn
      def initialize
        @access_token = ACCESS_TOKEN
      end
    end

    def setup
      @c = UsingConn.new  
    end

    def test_get_token
      assert_equal ACCESS_TOKEN, @c.get_token
    end

    def test_get_auth_headers
      auth_key = "authorization"
      
      @c = UsingConn.new
      actual = @c.get_auth_headers
      assert actual.key? auth_key
      assert_equal "Bearer #{ACCESS_TOKEN}", actual.fetch(auth_key, "")
    end

    def test_do_connect
      path = "somepath"
      auth_headers = @c.get_auth_headers
      
      URI.expects(:open).with(path, auth_headers).returns(OpenStruct.new(read: API_QUOTE_RAW_RESPONSE))
      actual = @c.do_connect(path)

      assert "ok", actual["ok"]
      assert_kind_of Array, actual["symbol"]
      assert_equal "AAPL", actual["symbol"][0]
    end

    def test_do_connect_raises_http_error_on_exception
      URI.expects(:open).raises(OpenURI::HTTPError.new(stub(), stub()))
      @c.expects(:handle_error).raises(ClientError)

      assert_raises(ClientError) { @c.do_connect(stub()) }
    end

    def test_get_uri
      path_hash = {h: "base", q: "query"}
      URI::HTTPS.expects(:build).with(path_hash).returns({})

      actual = @c.get_uri(path_hash)
      assert_equal "{}", actual
    end

    def test_do_request_raises_if_do_connect_raises
      @c.expects(:do_connect).raises(ClientError)
      assert_raises(ClientError) { @c.do_request("", {})}
    end
    
    def test_do_request_works_as_expected
      @c.expects(:do_connect).returns({})
      actual = @c.do_request("", {})
      assert_equal({}, actual)
    end
  end
end