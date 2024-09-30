require 'market_data/constants'

module MarketData
  module Models
    include MarketData::Constants

    Quote = Struct.new(*Constants::QUOTE_FIELDS) do
      def blank?
        (QUOTE_FIELDS - [:symbol]).all? { |mmethod| self[mmethod].nil?}
      end
    end

    Candle = Struct.new(*Constants::CANDLE_FIELDS) do
      def blank?
        (CANDLE_FIELDS - [:symbol]).all? { |mmethod| self[mmethod].nil?}
      end
    end
  end
end