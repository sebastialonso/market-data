require 'market_data/conn'
require 'market_data/errors'
require 'market_data/mappers'
require 'market_data/validations'

module MarketData
  module Quotes
    include MarketData::Mappers
    include MarketData::Errors
    include MarketData::Conn
    include MarketData::Validations

    @@single = "/v1/stocks/quotes/"
    @@bulk = "/v1/stocks/bulkquotes/"
    @@candles = "/v1/stocks/candles/"
    @@bulk_candles = "/v1/stocks/bulkcandles/"
    @@earnings = "/v1/stocks/earnings/"

    def quote(symbol, w52 = false, extended = false)
      query = validate_quotes_input!(symbol: symbol, w52: w52, extended: extended)
      
      path_hash = { host: MarketData.base_host, path: @@single + symbol }
      if !query.empty?
        path_hash[:query] = URI.encode_www_form(query)
      end
      
      res = do_connect(get_uri path_hash)
      map_quote(res)
    end

    def bulk_quotes(symbols, snapshot = false, extended = false)
      query = validate_bulk_quotes_input!(symbols: symbols, snapshot: snapshot, extended: extended)
      
      path_hash = { host: MarketData.base_host, path: @@bulk  }
      path_hash[:query] = URI.encode_www_form(query)

      res = do_connect(get_uri path_hash)
      map_bulk_quotes res
    end
  
    def candles(symbol, opts = {})
      defaults = {resolution: "D", from: nil, to: Time.now.utc.to_i, countback: nil}
      opts = defaults.merge(opts)
      query =  validate_candles_input!(**opts)
      
      path_hash = { host: MarketData.base_host, path: @@candles + opts[:resolution] + "/" + symbol }
      path_hash[:query] = URI.encode_www_form(query)
      
      res = do_connect(get_uri path_hash)
      map_candles res, symbol
    end

    def bulk_candles(symbols, resolution = "D")
      query = validate_bulk_candles_input!(symbols: symbols, resolution: resolution)
      query = query.except(:resolution)
      
      path_hash = { host: MarketData.base_host, path: @@bulk_candles + resolution + "/" }
      path_hash[:query] = URI.encode_www_form(query)
      
      res = do_connect(get_uri path_hash)
      map_bulk_candles res
    end

    def earnings(symbol, opts = {from: nil, to: nil, countback: nil, date: nil, report: nil})
      path_hash = { host: MarketData.base_host(), path: @@earnings + symbol}
      query = validate_earnings_input!(**opts)
      path_hash[:query] = URI.encode_www_form(query)

      res = do_connect(get_uri path_hash)
      map_earning res
    end
  end
end

