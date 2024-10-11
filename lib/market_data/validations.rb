require 'date'

module MarketData
  module Validations
    include MarketData::Errors
    
    VALID_DAILY_RESOLUTION = ['daily', 'D', '1D', '2D', '3D', '4D', '5D']
    VALID_RESOLUTIONS = [
      *VALID_DAILY_RESOLUTION,
      'weekly', 'W', '1W', '2W', '3W', '4W', '5W',
      'monthly', 'M', '1M', '2M', '3M', '4M', '5M',
      'yearly', 'Y', '1Y', '2Y', '3Y', '4Y', '5Y',
    ]

    def validate_quotes_input!(symbol: nil, w52: nil, extended: nil)
      result = {}
    
      if w52
        result.merge!({"52week" => true})
      end
      # MarketData API considers extended as true by default. Should be included
      # in the query when false
      if !extended
        result.merge!({extended: false})
      end
      
      result
    end
    
    def validate_bulk_quotes_input!(symbols: nil, snapshot: nil, extended: nil)
      result = {extended: false}
      if snapshot
        result.merge!({snapshot: true})
      else
        if !symbols.kind_of?(Array) || symbols.size < 2
          raise BadParameterError.new("symbols must be list with at least 2 symbols")
        end
        result.merge!({symbols: symbols.join(",")})
      end
      if extended
        result.merge!({extended: true})
      end
      
      result
    end

    def validate_bulk_candles_input!(resolution: nil, symbols: nil)
      s, r = validate_resolution(resolution, VALID_DAILY_RESOLUTION)
      if s == :invalid
        raise BadParameterError.new(r)
      end
      if !symbols.kind_of?(Array) || symbols.size < 2
        raise BadParameterError.new("symbols must be list with at least 2 symbols")
      end

      r.merge({symbols: symbols.join(",")})
    end

    def validate_candles_input!(resolution: nil, from: nil, to: nil, countback: nil)
      state, response = validate_from_to_countback_strategy(from: from, to: to, countback: countback)
      if state == :invalid
        raise BadParameterError.new(response)
      end

      state, res = validate_resolution(resolution)
      if state == :invalid
        raise BadParameterError.new(res)
      end

      response.merge(res)
    end
    
    def validate_earnings_input!(from: nil, to: nil, countback: nil, date: nil, report: nil)
      if !date.nil?
        return {date: date}
      end
      if !report.nil?
        return {report: report}
      end
      
      state, response = validate_from_to_countback_strategy(from: from, to: to, countback: countback)
      if state == :invalid
        raise BadParameterError.new(response)
      end

      return response
    end

    def validate_market_status_input!(country: nil, date: nil, from: nil, to: nil, countback: nil)
      result = {}

      if [country, date, from, to, countback].all? { |x| x.nil? }
        return result
      end

      if !country.nil?
        result.merge!({country: country})  
      end
      
      if !date.nil?
        # date has higher priority than from-to-countback
        return result.merge({date: date})
      end

      if [from, to, countback].all? { |x| x.nil? }
        return result
      else
        state, response = validate_from_to_countback_strategy(from: from, to: to, countback: countback)
        if state == :invalid
          raise BadParameterError.new(response)
        end
      end

      return result.merge(response)
    end

    def validate_from_to_countback_strategy(
      from: nil, to: nil, countback: nil
    )
      if !from.nil? && !to.nil?
        return :valid, {from: from, to: to}
      end
      if !to.nil? && !countback.nil? && from.nil?
        return :valid, {to: to, countback: countback}
      end
      
      return :invalid, "supply either :from and :to, or :to and :countback"
    end

    def validate_resolution resolution, allowed_values = VALID_RESOLUTIONS
      if VALID_RESOLUTIONS.include? resolution
        return :valid, {resolution: resolution}
      end
      return :invalid, "invalid resolution: #{resolution}"
    end
    
    def time_valid?(t)
      if t.kind_of?(String)
        begin
          DateTime.iso8601(t)
          return true
        rescue
          return false
        end
      end
      if t.kind_of?(Integer)
        return t > 0
      end
    end
  end
end