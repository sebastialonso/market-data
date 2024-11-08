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

    SIDE_CALL = "Call"
    SIDE_PUT = "Put"

    RANGE_ALL = "all"
    RANGE_OTM = "otm"
    RANGE_ITM = "itm"
    RANGE_ALLOWED = [RANGE_ALL, RANGE_OTM, RANGE_ITM]

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
      high52: "52weekHigh",
      low52: "52weekLow",
    }
    MARKET_STATUS_FIELD_MAPPING = {
      date: "date",
      status: "status"
    }
    INDEX_QUOTE_FIELD_MAPPING = {
      symbol: "symbol",
      last: "last",
      change: "change",
      change_pct: "changepct",
      high52: "52weekHigh",
      low52: "52weekLow",
      updated: "updated",
    }
    INDEX_CANDLE_FIELD_MAPPING = {
      symbol: "symbol",
      open: "o",
      close: "c",
      low: "l",
      high: "h",
      time: "t",
    }
    OPTION_CHAIN_FIELD_MAPPING = {
      option_symbol: "optionSymbol",
      underlying: "underlying",
      expiration: "expiration",
      side: "side",
      strike: "strike",
      first_traded: "firstTraded",
      dte: "dte",
      ask: "ask",
      ask_size: "askSize",
      bid: "bidSize",
      mid: "mid",
      last: "last",
      volume: "volume",
      open_interest: "openInterest",
      underlying_price: "underlyingPrice",
      in_the_money: "inTheMoney",
      intrinsic_value: "intrinsicValue",
      extrinsic_value: "extrinsicValue",
      updated: "updated",
      iv: "iv",
      delta: "delta",
      gamma: "gamma",
      theta: "theta",
      vega: "vega",
      rho: "rho"
    }
    OPTION_QUOTE_FIELD_MAPPING = {
      option_symbol: "optionSymbol",
      ask: "ask",
      ask_size: "askSize",
      bid: "bid",
      bid_size: "bidSize",
      mid: "mid",
      last: "last",
      volume: "volume",
      open_interest: "openInterest",
      underlying_price: "underlyingPrice",
      in_the_money: "inTheMoney",
      updated: "updated",
      iv: "iv",
      delta: "delta",
      gamma: "gamma",
      theta: "theta",
      vega: "vega",
      rho: "rho",
      intrinsic_value: "intrinsicValue",
      extrinsic_value: "extrinsicValue"
    }
  end
end