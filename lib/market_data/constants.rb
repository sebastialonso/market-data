module MarketData
  module Constants
    SECOND = 1
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = HOUR * 24
    WEEK = DAY * 7
    YEAR = DAY * 365

    QUOTE_FIELDS = [:symbol, :ask, :askSize, :bid, :bidSize, :mid, :last, :change, :changepct, :volume, :updated, :high52, :low52]
    CANDLE_FIELDS = [:symbol, :open, :high, :low, :close, :volume, :time]
  end
end