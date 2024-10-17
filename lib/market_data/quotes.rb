require 'market_data/conn'
require 'market_data/errors'
require 'market_data/mappers'
require 'market_data/validations'

module MarketData
  module Quotes
    include MarketData::Mappers
    include MarketData::Errors # <- TODO: remove this
    include MarketData::Conn
    include MarketData::Validations

    @@single = "/v1/stocks/quotes/"
    @@bulk = "/v1/stocks/bulkquotes/"
    @@candles = "/v1/stocks/candles/"
    @@bulk_candles = "/v1/stocks/bulkcandles/"
    @@earnings = "/v1/stocks/earnings/"

    def quote(symbol, w52 = false, extended = false)
      query = validate_quotes_input!(symbol: symbol, w52: w52, extended: extended)

      map_quote(
        do_request @@single + symbol, query
      )
    end

    def bulk_quotes(symbols, snapshot = false, extended = false)
      query = validate_bulk_quotes_input!(symbols: symbols, snapshot: snapshot, extended: extended)
      
      map_bulk_quotes(
        do_request @@bulk, query
      )
    end
  
    def candles(symbol, opts = {})
      defaults = {resolution: "D", from: nil, to: Time.now.utc.to_i, countback: nil}
      opts = defaults.merge(opts)
      query =  validate_candles_input!(**opts)
      
      map_candles(
        do_request(@@candles + opts[:resolution] + "/" + symbol, query),
        symbol
      )
    end

    def bulk_candles(symbols, resolution = "D")
      query = validate_bulk_candles_input!(symbols: symbols, resolution: resolution)
      query = query.except(:resolution)
      
      map_bulk_candles(
        do_request @@bulk_candles + resolution + "/", query
      )
    end

    def earnings(symbol, opts = {from: nil, to: nil, countback: nil, date: nil, report: nil})
      query = validate_earnings_input!(**opts)

      map_earning(
        do_request @@earnings + symbol, query
      )
    end
  end
end

