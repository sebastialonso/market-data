require 'market_data/conn'
require 'market_data/errors'
require 'market_data/mappers'

module MarketData
  module Quotes
    include MarketData::Mappers
    include MarketData::Errors
    include MarketData::Conn

    @@single = "/v1/stocks/quotes/"
    @@bulk = "/v1/stocks/bulkquotes/"
    @@candles = "/v1/stocks/candles/"
    @@bulk_candles = "/v1/stocks/bulkcandles/"

    def quote(symbol, w52 = false)
      path_hash = { host: MarketData.base_host, path: @@single + symbol }
      if w52
        path_hash[:query] = URI.encode_www_form({"52week" => true })
      end
      res = do_connect(get_uri path_hash)
      map_quote(res)
    end

    def bulk_quotes(symbols, snapshot = false)
      path_hash = { host: MarketData.base_host, path: @@bulk  }
      query_hash = {}
      
      if snapshot
        query_hash[:snapshot] = true
      else
        if !symbols.is_a?(Array) || symbols.size < 1
          raise BadParameterError.new("symbols must be a non-empty list")
        end
        query_hash = { symbols: symbols.join(",") }
      end
      
      path_hash[:query] = URI.encode_www_form(query_hash)

      res = do_connect(get_uri path_hash)
      map_bulk_quotes res
    end
  
    def candles(symbol, opts = {})
      defaults = {resolution: "D", from: nil, to: Time.now.utc.to_i, countback: nil}
      opts = defaults.merge(opts)
      
      query_hash = {to: opts[:to]}
    
      # TODO Move method validations into own class
      # TODO check to is either iso8601 or unix
      if opts[:from].nil? && opts[:countback].nil?
        raise BadParameterError.new("either :from or :countback must be supplied")
      end

      if opts[:from].nil?
        query_hash[:countback] = opts[:countback]
      else
        query_hash[:from] = opts[:from]
      end
      
      path_hash = { host: MarketData.base_host, path: @@candles + opts[:resolution] + "/" + symbol }
      path_hash[:query] = URI.encode_www_form(query_hash)
      
      res = do_connect(get_uri path_hash)
      map_candles res, symbol
    end

    def bulk_candles(symbols, resolution = "D")
      unless resolution == "daily" || resolution == "1D" || resolution == "D"
        raise BadParameterError.new("only daily resolution is allowed for this endpoint")
      end
      path_hash = { host: MarketData.base_host, path: @@bulk_candles + resolution + "/" }
      
      if !symbols.is_a?(Array) || symbols.size < 1
        raise BadParameterError.new("symbols must be a non-empty list")
      end
      query_hash = { symbols: symbols.join(",") }

      path_hash[:query] = URI.encode_www_form(query_hash)

      res = do_connect(get_uri path_hash)
      map_bulk_candles res
    end
  end
end

