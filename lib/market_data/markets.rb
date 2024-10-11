module MarketData
  module Markets
    include MarketData::Validations  
    
    @@status = "/v1/markets/status/"
    
    def market_status(country: nil, date: nil, from: nil, to: nil, countback: nil)
      query =  validate_market_status_input!(country: country, date: date, from: from, to: to, countback: countback)

      path_hash = { host: MarketData.base_host, path: @@status }
      path_hash[:query] = URI.encode_www_form(query)
      
      res = do_connect(get_uri path_hash)
      map_market_status res
    end
  end
end