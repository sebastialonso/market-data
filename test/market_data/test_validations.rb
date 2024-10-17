require "test_helper"

module MarketData
  class TestValidations < Minitest::Test
    include MarketData::Validations
    AAPL_QUOTE = "AAPL"
    STUB_STRIKE = 1

    class UsingValidations
      include MarketData::Validations  
    end

    def setup
      @invalid_validation = [:invalid, "validation error"]
      @from = Time.now - 1 * Constants::WEEK
      @to = Time.now
      @countback = 3
      @date = Time.now
      @report = "2023-4"
      @s = UsingValidations.new
      @ftc = {from: @from, to: @to, countback: @countback}
    end

    def test_validate_quotes_input_work_as_expected
      actual = validate_quotes_input!(symbol: AAPL_QUOTE, w52: true, extended: true)
      refute actual.key? :extended
      assert actual["52week"]
    end

    def test_validate_quotes_input_populates_extend
      actual = validate_quotes_input!(symbol: AAPL_QUOTE, extended: false)
      assert actual.key? :extended
      refute actual[:extended]
      refute actual["52week"]
    end

    def test_validate_bulk_quotes_input_raises_when_symbols_invalid
      assert_raises(BadParameterError) {@s.validate_bulk_quotes_input!(symbols: [])}
      assert_raises(BadParameterError) {@s.validate_bulk_quotes_input!(symbols: AAPL_QUOTE)}
    end

    def test_validate_bulk_quotes_input_ignores_symbols_if_snaphot_is_present
      actual = validate_bulk_quotes_input!(symbols: [AAPL_QUOTE, "AMD"], snapshot: true)
      assert actual[:snapshot]
      refute actual[:extended]
      assert_nil actual[:symbols]
    end

    def test_validate_bulk_quotes_input_works_as_expected
      actual = validate_bulk_quotes_input!(symbols: [AAPL_QUOTE, "AMD"], extended: true)
      refute actual[:snapshot]
      assert actual[:extended]
      assert_equal "AAPL,AMD", actual[:symbols]
    end

    def test_earnings_input_returns_with_date_strategy
      actual = validate_earnings_input!(date: @date, report: @report, from: @from, to: @to, countback: @countback)
      
      assert actual.key?(:date)
      assert_equal 1, actual.keys.size
      assert_equal @date, actual[:date]
    end

    def test_earnings_input_returns_with_report_strategy
      actual = validate_earnings_input!(report: @report, from: @from, to: @to, countback: @countback)
      
      assert actual.key?(:report)
      assert_equal 1, actual.keys.size
      assert_equal @report, actual[:report]
    end

    def test_earnings_input_returns_with_from_to_strategy
      actual = validate_earnings_input!(from: @from, to: @to, countback: @countback)

      assert actual.key?(:from)
      assert actual.key?(:to)
      assert_equal 2, actual.keys.size
      assert_equal @from, actual[:from]
      assert_equal @to, actual[:to]
    end

    def test_earnings_input_returns_with_countback_strategy
      actual = validate_earnings_input!(to: @to, countback: @countback)
      
      assert actual.key?(:countback)
      assert actual.key?(:to)
      assert_equal 2, actual.keys.size
      assert_equal @countback, actual[:countback]
      assert_equal @to, actual[:to]
    end

    def test_earnings_input_raises_when_invalid_set_of_parameters
      [
        {from: @from, countback: @countback},
      ].each do |set_of_params|
        assert_raises(BadParameterError) { validate_earnings_input!(**set_of_params) }  
      end
    end

    def test_validate_market_status_input_raises_from_invalid_from_to_countack_strategy
      @s.expects(:validate_from_to_countback_strategy).returns(@invalid_validation)

      assert_raises(BadParameterError) { @s.validate_market_status_input!(**@ftc) }
    end

    def test_validate_market_status_input_returns_with_from_to_countback_strategy
      actual = @s.validate_market_status_input!(**@ftc)

      assert_equal @ftc[:from], actual[:from]
      assert_equal @ftc[:to], actual[:to]
    end

    def test_validate_market_status_input_returns_with_no_from_to_countback_strategy
      actual = @s.validate_market_status_input!(country: "US")

      assert_equal 1, actual.keys.size
      assert actual.key? :country
    end

    def test_validate_market_status_input_returns_with_no_arguments
      actual = @s.validate_market_status_input!()
      assert_empty actual
    end

    def test_validate_market_status_input_returns_with_date
      args = {country: "US", date: Time.now.iso8601}
      actual = @s.validate_market_status_input!(**args)

      assert_equal args[:country], actual[:country]
      assert_equal args[:date], actual[:date]
      refute args.key? :to
    end
    
    def test_validate_index_quote_input_returns_with_arguments
      actual = @s.validate_index_quote_input!(w52: true)
      assert actual["52week"]
    end

    def test_validate_index_quote_input_returns_without_arguments
      assert_empty @s.validate_index_quote_input!
    end

    def test_time_valid_with_valid_string
      refute time_valid?("adas")
      refute time_valid?(Time.now.strftime("Printed on %m/%d/%Y") )
      refute time_valid?(-1)
      refute time_valid?(0)
      assert time_valid?(Time.now.iso8601)
      assert time_valid?(Time.now.to_i)
    end

    def test_validate_resolution_fails_when_invalid_resolution
      resolution = "WW"
      
      actual = validate_resolution resolution
      assert_equal 2, actual.size
      assert_equal actual[0], :invalid
      assert_includes actual[1], "WW"
    end

    def test_validate_resolution_works_as_expected
      actual = validate_resolution "D"
      assert_equal 2, actual.size
      assert_equal actual[0], :valid
      assert_equal actual[1], {resolution: "D"}
    end

    def test_validate_candles_input_raises_when_resolution_is_invalid
      @s.expects(:validate_from_to_countback_strategy).returns([:valid, {}])
      @s.expects(:validate_resolution).returns(@invalid_validation)
      
      assert_raises(BadParameterError) { @s.validate_candles_input!(resolution: "WW", **@ftc) }
    end

    def test_validate_candles_input_raises_when_from_to_countback_is_invalid
      @s.expects(:validate_from_to_countback_strategy).returns(@invalid_validation)
      
      assert_raises(BadParameterError) { @s.validate_candles_input!(**@ftc)}
    end

    def test_validate_candles_input_works_as_expected
      @s.expects(:validate_from_to_countback_strategy).returns([:valid, {a: 1}])
      @s.expects(:validate_resolution).returns([:valid, {b: 2}])

      actual = @s.validate_candles_input!(**{})
      assert_equal actual[:a], 1
      assert_equal actual[:b], 2
    end
    

    def test_validate_bulk_candles_input_raises_when_resolution_is_invalid
      @s.expects(:validate_resolution).returns(@invalid_validation)

      assert_raises(BadParameterError) {@s.validate_bulk_candles_input!(*{})}
    end

    def test_validate_bulk_candles_input_raises_when_symbols_are_invalid
      @s.expects(:validate_resolution).twice.returns([:valid, {}])
      assert_raises(BadParameterError) {@s.validate_bulk_candles_input!(resolution: "D", symbols: [])}
      assert_raises(BadParameterError) {@s.validate_bulk_candles_input!(resolution: "D", symbols: AAPL_QUOTE)}
    end

    def test_validate_bulk_candles_input_works_as_expected
      actual = @s.validate_bulk_candles_input!(symbols: [AAPL_QUOTE, "AMD"], resolution: "daily")

      assert_equal 2, actual.size
      assert_equal "AAPL,AMD", actual[:symbols]
      assert_equal "daily", actual[:resolution]
    end

    def test_validate_index_candles_input_raises_when_options_are_invalid
      @s.expects(:validate_candles_input!).raises(BadParameterError)
      assert_raises(BadParameterError)  {@s.validate_index_candles_input! }
    end

    def test_validate_expirations_input_raises_when_invalid_symbol
      # first: not a string
      assert_raises(BadParameterError) { @s.validate_expirations_input!(**{symbol: 2})}
      assert_raises(BadParameterError) { @s.validate_expirations_input!(**{symbol: ["SYM"]})}
      # second: empty string
      assert_raises(BadParameterError) { @s.validate_expirations_input!(**{symbol: ""})}
    end

    def test_validate_expirations_input_raises_when_invalid_date
      @s.expects(:time_valid?).returns(false)
      assert_raises(BadParameterError) { @s.validate_expirations_input!(**{date: Time.now, symbol: AAPL_QUOTE})}
    end

    def test_validate_expirations_input_raises_when_invalid_strike
      assert_raises(BadParameterError) { @s.validate_expirations_input!(**{strike: AAPL_QUOTE, symbol: AAPL_QUOTE, date: @date.to_i})}
    end

    def test_validate_expirations_input_runs_as_expected
      actual = @s.validate_expirations_input!(**{symbol: AAPL_QUOTE})
      assert_empty actual
      actual = @s.validate_expirations_input!(**{symbol: AAPL_QUOTE, strike: STUB_STRIKE})
      assert_equal 1, actual.keys.size
      assert actual.key? :strike
      assert_equal actual[:strike], STUB_STRIKE
      actual = @s.validate_expirations_input!(**{symbol: AAPL_QUOTE, date: @date.to_i})
      assert_equal 1, actual.keys.size
      assert actual.key? :date
      assert_equal actual[:date], @date.to_i
      actual = @s.validate_expirations_input!(**{symbol: AAPL_QUOTE, date: @date.to_i, strike: STUB_STRIKE})
      assert_equal 2, actual.keys.size
    end
  end
end