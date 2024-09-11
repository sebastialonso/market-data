module MarketData

  class ClientError < StandardError;end
  class UnauthorizedError < ClientError; end
  class BadParameterError < ClientError; end

  module Errors
    def handle_error e
      er = e.io
      case er.status[0]
      when "401"
        raise UnauthorizedError
      else 
        raise e
      end
    end
  end
  
end