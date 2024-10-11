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
  end
end