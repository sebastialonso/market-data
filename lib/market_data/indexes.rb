module MarketData
  module Indexes
    include MarketData::Conn
    include MarketData::Mappers
    include MarketData::Validations

    @@quotes = "/v1/indices/quotes/"
    @@candles = "/v1/indices/candles/"

    def index_quote(symbol, opts = {w52: nil})
      query = validate_index_quote_input!(**opts)

      map_index_quote(
        do_request(@@quotes + symbol, query)
      )
    end

    def index_candles(symbol, opts = {resolution: nil, from: nil, to: nil, countback: nil})
      query = validate_index_candles_input!(**opts)

      map_index_candles(
        do_request("#{@@candles}#{opts[:resolution]}/#{symbol}", query),
        symbol
      )
    end
  end
end