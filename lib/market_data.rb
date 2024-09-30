# frozen_string_literal: true

require_relative "market_data/version"
require "market_data/quotes"

module MarketData
  @@base_host = "api.marketdata.app"
  
  class Client
    include MarketData::Quotes
    # include MarketData::Index

    def initialize token
      @access_token = token
    end
  end

  def self.base_host
    @@base_host
  end
end