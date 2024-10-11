require 'market_data/models'

module MarketData
  module Mappers
    include MarketData::Models
    SYMBOL_RESPONSE_KEY = "symbol"
    STATUS_RESPONSE_KEY = "s"

    def map_quote response, i=0
      Quote.new(**map_fields_for(response, :quote, i))
    end

    def map_bulk_quotes response
      h = Hash.new
      (0..(response[SYMBOL_RESPONSE_KEY].size - 1)).each do |i|
        qquote = map_quote(response, i)
        h[response[SYMBOL_RESPONSE_KEY][i]] = !qquote.blank? ? qquote : nil
      end
      h
    end

    def map_candles response, symbol
      ar = []
      (0..(response["o"].size - 1)).each do |i|
        args = map_fields_for(response, :candle, i)
        args[:symbol] = symbol
        ar << Candle.new(**args)
      end
    
      ar
    end

    def map_bulk_candles response
      h = Hash.new
      (0..(response[SYMBOL_RESPONSE_KEY].size - 1)).each do |i|
        candle = Candle.new(**map_fields_for(response, :candle, i))
        h[response[SYMBOL_RESPONSE_KEY][i]] = !candle.blank? ? candle : nil
      end
      h
    end

    def map_earning response
      ar = []
      (0..(response[SYMBOL_RESPONSE_KEY].size - 1)).each do |i|
        ar << Earning.new(**map_fields_for(response, :earning, i))
      end
      ar
    end

    def map_fields_for(response, kind, i=0)
      mapping = {}
      case kind
      when :candle
        mapping = Constants::CANDLE_FIELD_MAPPING
      when :earning
        mapping = Constants::EARNING_FIELD_MAPPING
      when :quote
        mapping = Constants::QUOTE_FIELD_MAPPING
      else
        raise BadParameterError.new("unrecognized model for mapping: #{kind}")
      end
      
      r = {}
      mapping.each do |field, mapped|
        r.store(field, response.fetch(mapped, nil).nil? ? nil : response.fetch(mapped)[i])
      end
      r
    end
  end
end