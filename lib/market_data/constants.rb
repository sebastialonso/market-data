module MarketData
  module Constants
    SECOND = 1
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = HOUR * 24
    WEEK = DAY * 7
    MONTH_30 = DAY * 30
    MONTH_31 = DAY * 31
    YEAR = DAY * 365

    EARNING_FIELD_MAPPING = {
      symbol: "symbol",
      fiscal_year: "fiscalYear",
      fiscal_quarter: "fiscalQuarter",
      date: "date",
      report_date: "reportDate",
      report_time: "reportTime",
      currency: "currency",
      reported_eps: "reportedEPS",
      estimated_eps: "estimatedEPS",
      surprise_eps: "surpriseEPS",
      surprise_eps_pct: "surpriseEPSpct",
      updated: "updated"
    }
    CANDLE_FIELD_MAPPING = {
      symbol: "symbol",
      open: "o",
      close: "c",
      low: "l",
      high: "h",
      volume: "v",
      time: "t",
    }
    QUOTE_FIELD_MAPPING = {
      symbol: "symbol",
      ask: "ask",
      ask_size: "askSize",
      bid: "bid",
      bid_size: "bidSize",
      mid: "mid",
      last: "last",
      change: "change",
      change_pct: "changepct",
      volume: "volume",
      updated: "updated",
      high52: "high52",
      low52: "low52",
    }
  end
end