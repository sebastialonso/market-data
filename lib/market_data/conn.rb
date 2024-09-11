require 'open-uri'
require 'json'
require 'market_data/errors'

module MarketData
  module Conn
    include MarketData::Errors

    def do_connect(path)
      begin
        conn = URI.open(path, get_auth_headers) 
        JSON.parse(conn.read)
      rescue OpenURI::HTTPError => e
        handle_error e
      end
    end

    def get_uri(path_hash)
      URI::HTTPS.build(path_hash).to_s
    end

    def get_auth_headers
      { "authorization" => "Bearer #{get_token}"}
    end

    # Read from MarketData::Client parent
    def get_token
      @access_token
    end
  end
end