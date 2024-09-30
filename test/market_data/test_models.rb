require "test_helper"

module MarketData
  class TestConn < Minitest::Test
    
    def test_candle_blank_when_fields_filled
      c = Models::Candle.new(symbol: "AAPL", open: 100, high: 300, low: 300, close: 100, volume: 100, time: Time.now.to_i)
      refute c.blank?
    end

    def test_candle_blank_when_fields_empty
      c = Models::Candle.new(symbol: "AAPL")
      assert c.blank?
    end
  end
end