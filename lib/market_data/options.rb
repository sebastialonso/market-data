require 'market_data/conn'
require 'market_data/mappers'
require 'market_data/validations'

module MarketData
  module Options
    include MarketData::Conn
    include MarketData::Mappers
    include MarketData::Validations

    @@expirations = "/v1/options/expirations/%{symbol}/" 
    @@lookup = "/v1/options/lookup/" 
    @@strike = "/v1/options/strikes/%{symbol}/"
    @@chain = "/v1/options/chain/%{symbol}/"
    @@quotes = "/v1/options/quotes/%{symbol}/"

    def expirations(symbol, opts = options_for_expirations)
      query = validate_expirations_input!(symbol: symbol, **opts)
      
      map_expirations(
        do_request(
          @@expirations % {symbol: symbol},
          query
        )
      )
    end

    def lookup(required = required_for_lookup)
      query = validate_lookup_input!(**required)
      s_query = "#{query[:symbol]} #{query[:expiration]} #{query[:strike]} #{query[:side]}"
      
      map_lookup(
        do_request @@lookup + encode_uri_component(s_query), {}
      )
    end

    def strikes(symbol, opts = options_for_strikes)
      query = validate_strikes_input!(symbol: symbol, **opts)
      query = query.except(:symbol)

      map_strike(
        do_request @@strike % {symbol: symbol}, query
      )
    end

    def chain(symbol, opts = options_for_option_chains)
      query = validate_option_chain_input!(symbol: symbol, **opts)
      query = query.except(:symbol)

      map_option_chain(
        do_request @@chain % {symbol: symbol}, query
      )
    end

    def option_quote(symbol, opts = options_for_option_quote)
      query = validate_option_quote_input!(symbol: symbol, **opts)
      query = query.except(:symbol)

      map_option_quote(
        do_request @@quotes % {symbol: symbol}, query
      )
    end
  end
end