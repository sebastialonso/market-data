require 'market_data/models'

module MarketData
  module Mappers
    include MarketData::Models

    SYMBOL_RESPONSE_KEY = "symbol"
    STATUS_RESPONSE_KEY = "s"

    def map_quote response, i=0
      Quote.new(
        symbol: response["symbol"][i],
        ask: response["ask"][i],
        askSize: response["askSize"][i],
        bid: response["bid"][i],
        bidSize: response["bidSize"][i],
        mid: response["mid"][i],
        last: response["last"][i],
        change: response["change"][i],
        changepct: response["changepct"][i],
        volume: response["volume"][i],
        updated: response["updated"][i],
        high52: response.fetch("high52", nil),
        low52: response.fetch("low52", nil),
      )
    end

    def map_bulk_quotes response
      h = Hash.new
      size = response[SYMBOL_RESPONSE_KEY].size
      for i in 0..(size - 1) do
        qquote = map_quote(response, i)
        h[response[SYMBOL_RESPONSE_KEY][i]] = !qquote.blank? ? qquote : nil
      end
      h
    end

    def map_candles response, symbol
      ar = []
      size = response["o"].size
    
      for i in 0..(size - 1) do
        ar << Candle.new(
          open: response["o"][i],
          high: response["h"][i],
          low: response["l"][i],
          close: response["c"][i],
          volume: response["v"][i],
          time: response["t"][i],
          symbol: symbol
        )
      end
      ar
    end

    def map_bulk_candles response
      h = Hash.new
      size = response[SYMBOL_RESPONSE_KEY].size
    
      for i in 0..(size - 1) do
        candle = Candle.new(symbol: response["symbol"][i], open: response["o"][i], high: response["h"][i], low: response["l"][i], close: response["c"][i], volume: response["v"][i], time: response["t"][i])
        h[response[SYMBOL_RESPONSE_KEY][i]] = !candle.blank? ? candle : nil
      end
      h
    end
  end
end