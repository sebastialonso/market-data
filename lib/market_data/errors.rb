require 'json'

module MarketData

  class ClientError < StandardError;end
  class UnauthorizedError < ClientError; end
  class RateLimitedError < ClientError; end
  class BadParameterError < ClientError; end
  class NotFoundError < ClientError; end

  module Errors
    def handle_error e
      er = e.io
      parsed_info = JSON.parse(er.string)
      case er.status[0]
      when "400"
        if parsed_info["s"] == "error"
          raise BadParameterError.new(parsed_info["errmsg"])
        end
        raise BadParameterError
      when "404"
        if parsed_info["s"] == "no_data"
            raise NotFoundError.new("no candle information was found for the request")  
        end
        raise NotFoundError
      when "401"
        raise UnauthorizedError.new(parsed_info["errmsg"])
      when "429"
        raise RateLimitedError
      else 
        raise e
      end
    end
  end
  
end