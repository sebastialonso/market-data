require 'market_data/conn'
require 'market_data/errors'

module MarketData
  module Quotes
    include MarketData::Errors
    include MarketData::Conn

    SYMBOL_RESPONSE_KEY = "symbol"
    STATUS_RESPONSE_KEY = "s"

    QUOTE_FIELDS = [:symbol, :ask, :askSize, :bid, :bidSize, :mid, :last, :change, :changepct, :volume, :updated, :high52, :low52]
    @@single = "/v1/stocks/quotes/"
    @@bulk = "/v1/stocks/bulkquotes/"

    # Quote is the struct to hold ticker request information
    Quote = Struct.new(*QUOTE_FIELDS) do
      def blank?
        (QUOTE_FIELDS - [:symbol]).all? { |mmethod| self[mmethod].nil?}
      end
    end
    
    def fetch(symbol, w52 = false)
      path_hash = { host: MarketData.base_host, path: @@single + symbol }
        if w52
          path_hash[:query] = URI.encode_www_form({"52week" => true })
        end
        res = do_connect(get_uri path_hash)
        Quote.new(*res.except(STATUS_RESPONSE_KEY).values.map { |ar| ar[0] })
    end

    def bulk_quotes(symbols, snapshot = false)
      unless symbols.is_a?(Array) && symbols.size > 1
        raise BadParameterError.new("symbols must be a non-empty list")
      end

      path_hash = { host: MarketData.base_host, path: @@bulk  }
      query_hash = { symbols: symbols.join(",") }
      if snapshot
        query_hash[:snapshot] = true
      end
      path_hash[:query] = URI.encode_www_form(query_hash)

      res = do_connect(get_uri path_hash)
      Quotes.map_quotes(res)
    end

    def self.map_quotes(quotes)
      h = Hash.new
      size = quotes[SYMBOL_RESPONSE_KEY].size
      p size
      for i in 0..(size - 1) do
        qquote = Quote.new(*quotes.except(STATUS_RESPONSE_KEY).values.map { |ar| ar[i] })
        h[quotes[SYMBOL_RESPONSE_KEY][i]] = !qquote.blank? ? qquote : nil
      end
      h
    end
  end
end

