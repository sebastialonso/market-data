require 'market_data/constants'

module MarketData
  module Models
    Quote = Struct.new(*Constants::QUOTE_FIELD_MAPPING.keys) do
      def blank?
        (Constants::QUOTE_FIELD_MAPPING.keys - [:symbol]).all? { |mmethod| self[mmethod].nil?}
      end
    end

    Candle = Struct.new(*Constants::CANDLE_FIELD_MAPPING.keys) do
      def blank?
        (Constants::CANDLE_FIELD_MAPPING.keys - [:symbol]).all? { |mmethod| self[mmethod].nil?}
      end
    end

    Earning = Struct.new(*Constants::EARNING_FIELD_MAPPING.keys)
    
    MarketStatus = Struct.new(*Constants::MARKET_STATUS_FIELD_MAPPING.keys)
    
    IndexQuote = Struct.new(*Constants::INDEX_QUOTE_FIELD_MAPPING.keys)

    IndexCandle = Struct.new(*Constants::INDEX_CANDLE_FIELD_MAPPING.keys)

    OptExpirations = Struct.new(:expirations, :updated)

    OptStrike = Struct.new(:updated, :strikes)

    OptChain = Struct.new(*Constants::OPTION_CHAIN_FIELD_MAPPING.keys)

    OptQuote = Struct.new(*Constants::OPTION_QUOTE_FIELD_MAPPING.keys)
  end
end