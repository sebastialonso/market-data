require 'market_data/conn'
require 'market_data/mappers'
require 'market_data/validations'

module MarketData
  module Options
    include MarketData::Conn
    include MarketData::Mappers
    include MarketData::Validations

    # TODO use delayed interpolation: https://stackoverflow.com/a/29172345/1296980
    @@expirations = "/v1/options/expirations/%{symbol}/" 

    def expirations(symbol, opts = {strike: nil, date: nil})
      query = validate_expirations_input!(symbol: symbol, **opts)
      
      map_expirations(
        do_request(
          @@expirations % {symbol: symbol},
          query
        )
      )
    end
  end
end