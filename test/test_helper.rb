# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter "test/"
  add_group 'lib', 'lib/'
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "market_data"

require "minitest/autorun"
require 'mocha/minitest'


