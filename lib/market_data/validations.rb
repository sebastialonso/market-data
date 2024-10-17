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

    def options_for_expirations
      {strike: nil, date: nil}
    end

    def required_for_lookup
      {symbol: nil, expiration: nil, strike: nil, side: nil}
    end

    def options_for_strikes
      {
        date: nil, expiration: nil
      }
    end
    
    def options_for_option_chains
      {
        date: nil,
        expiration: nil, dte: nil, from: nil, to: nil, month: nil, year: nil, weekly: nil, monthly: nil, quarterly: nil,
        strike: nil, delta: nil, strike_limit: nil, range: nil,
        min_bid: nil, max_bid: nil, min_ask: nil, max_ask: nil, max_bid_ask_spread: nil, max_bid_ask_spread_pct: nil, min_open_interest: nil, min_volume: nil,
        non_standard: nil, side: nil, am: nil, pm: nil
      }
    end

    def options_for_option_quote
      {
        date: nil, to: nil, from: nil
      }
    end

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

        return result.merge(response)
      end
    end
    
    def validate_index_quote_input!(w52: nil)
      if w52.nil? || !w52
        return {}
      end
      {"52week" => w52}
    end

    def validate_index_candles_input!(resolution: nil, from: nil, to: nil, countback: nil)
      validate_candles_input!(resolution: resolution, from: from, to: to, countback: countback)
    end

    def validate_expirations_input!(symbol: nil, strike: nil, date: nil)
      result = {}
      if !symbol.kind_of? String
        raise BadParameterError.new("symbol must be a string: found #{symbol}")
      end
      if symbol.empty?
        raise BadParameterError.new("symbol must be present: found empty string")
      end

      if !date.nil? && !time_valid?(date)
        raise BadParameterError.new("date is not valid")
      end
      result.merge!({date: date}) unless date.nil?
      
      if !strike.nil? && !strike.kind_of?(Numeric)
        raise BadParameterError.new("strike must be number, found: #{strike}")
      end
      result.merge!({strike: strike}) unless strike.nil?

      return result
    end

    def validate_lookup_input!(symbol: nil, expiration: nil, strike: nil, side: nil)
      raise BadParameterError.new("symbol must be present. Found :#{symbol}") if symbol.nil? || symbol.empty?
      raise BadParameterError.new("expiration must be present. Found :#{expiration}") if expiration.nil? || expiration.empty?
      raise BadParameterError.new("strike must be present. Found :#{symbol}") if strike.nil?
      if side.nil? || ![Constants::SIDE_CALL, Constants::SIDE_PUT].include?(side)
        raise BadParameterError.new("side must be either '#{Constants::SIDE_PUT}' or '#{Constants::SIDE_CALL}'. Found: '#{symbol}'")
      end
      return {symbol: symbol, expiration: expiration, strike: strike, side: side}
    end

    def validate_strikes_input!(symbol: nil, date: nil, expiration: nil)
      if symbol.nil? || symbol.empty?
        raise BadParameterError.new("symbol must be present. Found: #{symbol}")
      end
      result = {symbol: symbol}

      if !date.nil?
        raise BadParameterError.new("invalid date: #{date}") if !time_valid?(date)
        return result.merge({date: date})
      end

      if !expiration.nil?
        raise BadParameterError.new("invalid date: #{expiration}") if !time_valid?(expiration)
        result.merge!({expiration: expiration})
      end

      result
    end

    def validate_option_chain_input!(
      symbol: nil, date: nil, 
      expiration: nil, dte: nil, from: nil, to: nil, month: nil, year: nil, weekly: nil, monthly: nil, quarterly: nil,
      strike: nil, delta: nil, strike_limit: nil, range: nil,
      min_bid: nil, max_bid: nil, min_ask: nil, max_ask: nil, max_bid_ask_spread: nil, max_bid_ask_spread_pct: nil, min_open_interest: nil, min_volume: nil,
      non_standard: nil, side: nil, am: nil, pm: nil
    )
      result = {}
      
      if symbol.nil? || !symbol.kind_of?(String) || symbol.empty?
        raise BadParameterError.new("symbol must be present. Found: #{symbol}")
      end
      
      if !date.nil?
        raise BadParameterError.new("invalid date for `date`: #{date}") if !time_valid?(date)
        result.merge!({date: date})
      end
      
      # handle expiration filters
      e_filters = {expiration: expiration, dte: dte, from: from, to: to, month: month, year: year, weekly: weekly, monthly: monthly, quarterly: quarterly}
      expiration_filters_validated_query = validate_expiration_filters!(**e_filters)
      result.merge!(expiration_filters_validated_query)

      # handle strike filters
      s_filters = {strike: strike, delta: delta, strike_limit: strike_limit, range: range}
      strike_filters_validated_query = validate_option_chain_strike_filters!(**s_filters)
      result.merge!(strike_filters_validated_query)

      # handle liquidity filters
      l_filters = {min_bid: min_bid, max_bid: max_bid, min_ask: min_ask, max_ask: max_ask, max_bid_ask_spread: max_bid_ask_spread,
        max_bid_ask_spread_pct: max_bid_ask_spread_pct, min_open_interest: min_open_interest, min_volume: min_volume}
      liquidity_filters_validated_query = validate_option_chain_liquidity_filters!(**l_filters)
      result.merge!(liquidity_filters_validated_query)

      # handle other filters
      o_filters = {non_standard: non_standard, side: side, am: am, pm: pm}
      other_filters_validated_query = validate_option_chain_other_filters!(**o_filters)
      result.merge!(other_filters_validated_query)
    end

    # private methods
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
      false
    end

    def validate_expiration_filters!(
      expiration: nil, dte: nil, from: nil, to: nil, month: nil, year: nil, weekly: nil, monthly: nil, quarterly: nil
    )
      result = {}

      if !expiration.nil?
        raise BadParameterError.new("invalid date for `expiration`: #{expiration}") if expiration != "all" && !time_valid?(expiration)
        result.merge!({expiration: expiration})
      end

      # dte is exclusive with from & to
      if [dte, to, from].count(nil) == 0
        raise BadParameterError.new("either `dte` or (`from` and `to`) must be present")
      end

      if !dte.nil?
        raise BadParameterError.new("invalid value for `dte`: should be an integer") if !dte.kind_of? Integer
        result.merge!({dte: dte})
      end

      to_from_present = [from, to].count(nil)
      if to_from_present == 1
        raise BadParameterError.new("either none or both `from` and `to` must be included")
      end
      if to_from_present == 0
        raise BadParameterError.new("invalid date `from`: #{from}") if !time_valid?(from)
        raise BadParameterError.new("invalid date `to`: #{to}") if !time_valid?(to)
        result.merge!({from: from, to: to})
      end

      if !month.nil?
        if !month.kind_of?(Integer) || month > 12 || month < 1
          raise BadParameterError.new("`month` must be a number between 1 and 12 both inclusive") 
        end
        result.merge!({month: month})
      end

      if !year.nil?
        if !year.kind_of?(Integer) || year < 1920
          raise BadParameterError.new("`year` must be a number greater or equal than 1920") 
        end
        result.merge!({year: year})
      end

      timely_present = [weekly, monthly, quarterly].reject { |x| x.nil? }
      
      # check boolean-ness
      all_boolean = timely_present.all? { |x| x.kind_of?(FalseClass) || x.kind_of?(TrueClass)}
      raise BadParameterError.new("`weekly`, `monthly` and `quarterly` must be either true or false or nil") if !all_boolean
      
      # check all are the same
      all_true = timely_present.all? { |x| x.kind_of?(TrueClass)}
      all_false = timely_present.all? { |x| x.kind_of?(FalseClass)}
      raise BadParameterError.new("if two or more of `weekly`, `monthly` and `quarterly` are supplied, they must all have the same value") if !all_true && !all_false
      result.merge!({weekly: weekly}) if !weekly.nil?
      result.merge!({monthly: monthly}) if !monthly.nil?
      result.merge!({quarterly: quarterly}) if !quarterly.nil?

      result
    end

    def validate_option_chain_strike_filters!(
      strike: nil, delta: nil, strike_limit: nil, range: nil
    )
      result = {}
      if !strike.nil?
        raise BadParameterError.new("`strike` must be string") if !strike.kind_of?(String)
        result.merge!({strike: strike})
      end

      if !delta.nil?
        raise BadParameterError.new("`delta` must be string") if !delta.kind_of?(String)
        result.merge!({delta: delta})
      end

      if !strike_limit.nil?
        raise BadParameterError.new("`strike_limit` must be a number") if !strike_limit.kind_of?(Numeric)
        result.merge!({strikeLimit: strike_limit})
      end

      if !range.nil?
        if !Constants::RANGE_ALLOWED.include?(range)
          raise BadParameterError.new("`range` must be either nil or one of: `itm`,`otm`,`all`")
        else
          result.merge!({range: range})
        end
      end
      result
    end
    
    def validate_option_chain_liquidity_filters!(
      min_bid: nil, max_bid: nil, min_ask: nil, max_ask: nil, max_bid_ask_spread: nil,
      max_bid_ask_spread_pct: nil, min_open_interest: nil, min_volume: nil
    )
      result = {}
      if !min_bid.nil?
        raise BadParameterError.new("`min_bid` must be a number") if !min_bid.kind_of?(Numeric)
        result.merge!({minBid: min_bid})
      end
      if !max_bid.nil?
        raise BadParameterError.new("`max_bid` must be a number") if !max_bid.kind_of?(Numeric)
        result.merge!({maxBid: max_bid})
      end
      if !min_ask.nil?
        raise BadParameterError.new("`min_ask` must be a number") if !min_ask.kind_of?(Numeric)
        result.merge!({minAsk: min_ask})
      end
      if !max_ask.nil?
        raise BadParameterError.new("`max_ask` must be a number") if !max_ask.kind_of?(Numeric)
        result.merge!({maxAsk: max_ask})
      end
      if !max_bid_ask_spread.nil?
        raise BadParameterError.new("`max_bid_ask_spread` must be a number") if !max_bid_ask_spread.kind_of?(Numeric)
        result.merge!({maxBidAskSpread: max_bid_ask_spread})
      end
      if !max_bid_ask_spread_pct.nil?
        raise BadParameterError.new("`max_bid_ask_spread_pct` must be a number") if !max_bid_ask_spread_pct.kind_of?(Numeric)
        result.merge!({maxBidAskSpreadPct: max_bid_ask_spread_pct})
      end
      if !min_open_interest.nil?
        raise BadParameterError.new("`min_open_interest` must be a number") if !min_open_interest.kind_of?(Numeric)
        result.merge!({minOpenInterest: min_open_interest})
      end
      if !min_volume.nil?
        raise BadParameterError.new("`min_volume` must be a number") if !min_volume.kind_of?(Numeric)
        result.merge!({minVolume: min_volume})
      end
      result
    end

    def validate_option_chain_other_filters!(non_standard: nil, side: nil, am: nil, pm: nil)
      result = {}
      if !non_standard.nil?
        raise BadParameterError.new("`non_standard` can be either nil or a boolean") if ![FalseClass, TrueClass].include?(non_standard.class)
        result.merge!({nonstandard: non_standard}) if non_standard
        
      end
      if !side.nil?
        if ![Constants::SIDE_CALL.downcase, Constants::SIDE_PUT.downcase].include?(side)
          raise BadParameterError.new("`side` must be either '#{Constants::SIDE_PUT.downcase}' or '#{Constants::SIDE_CALL.downcase}'. Found: '#{side}'")
        end
        result.merge!({side: side})
      end
      if !am.nil?
        raise BadParameterError.new("`non_standard` can be either nil or a boolean") if ![FalseClass, TrueClass].include?(am.class)
        result.merge!({am: am})
      end
      if !pm.nil?
        raise BadParameterError.new("`non_standard` can be either nil or a boolean") if ![FalseClass, TrueClass].include?(pm.class)
        result.merge!({pm: pm})
      end
      result
    end

    def validate_option_quote_input!(symbol: nil, date: nil, from: nil, to: nil)
      result = {}
      if symbol.nil? || !symbol.kind_of?(String) || symbol.empty?
        raise BadParameterError.new("symbol must be present. Found: #{symbol}")
      end

      if !date.nil?
        raise BadParameterError.new("invalid date: #{date}") if !time_valid?(date)
        return result.merge!({date: date})
      end

      if [to, from].count(nil) == 1
        raise BadParameterError.new("either none or both `to` and `from` must be present")
      end

      if [to, from].count(nil) == 0
        raise BadParameterError.new("invalid `to`: #{to}") if !time_valid?(to)
        raise BadParameterError.new("invalid `from`: #{from}") if !time_valid?(from)
        result.merge!({from: from, to: to})
      end
      
      result
    end
  end
end