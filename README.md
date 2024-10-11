# MarketData

A Ruby wrapper for the [MarketData API](https://www.marketdata.app/docs/api).

![coverage](https://img.shields.io/badge/coverage%3A-87.77%25-yellow.svg)

## Installation

    $ gem install market_data

## Usage

You must instantiate a `MarketData::Client` before running any method. You'll need your MarketData API token first.

    $ client = MarketData::Client.new "YOUR_API_TOKEN"
    
    $ client.quote("AAPL")
    $ => <struct MarketData::Models::Quote symbol="AAPL", ask=231.42, askSize=2, bid=231.4, .....

### Quotes
For getting a single quote, run the `quote` method just as the example above.

#### Optional parameters

* `w52`

For getting fields with 52-week low and high information, pass true as the `w52` parameter. 
    
    $ q = client.quote("AAPL", w52=true)
    $ => q.high52 = 252.11
    $ => q.low52 = 222.35    
**It is `false` by default.**

* `extended`

For getting a quote when market is on extended hours, you have to supply the `extended` parameter as true. 

**It is false by default**, so if you fetch a quote during extended hours without the parameter, you'll always get the quote at closing time.

### Bulk quotes

For getting multiple quotes in a single request, use the `bulk_candle` method.

    $ quotes = client.bulk_quotes(["AAPL", "AMD", "NOTAQUOTE])
    
    $ quotes["AMD"] => <struct MarketData::Models::Quote symbol="AMD", ask=150.42, askSize=2, bid=146.4, .....
    
    $ quotes["NOTAQUOTE"] = nil

If a quote is not found, the hashmap will return a nil value for that ticker's key.

#### Optional parameters

* `snapshot`

If snapshot is true, any supplied array of symbols will be ignored and a complete snapshot of the market ticker's will be returned.
    
    $ quotes = client.bulk_quotes([], snapshot = true)

    $ quotes["A"] => <struct MarketData::Models::Quote symbol="A", ask=56.32, askSize=45, bid=67, .....
    ....
    $ quotes["Z"] => <struct MarketData::Models::Quote symbol="Z", ask=25, askSize=3, bid=14.5, .....

**This could use all you API credits. Use with caution.**

* `extended`

For getting a quote when market is on extended hours, you have to supply the `extended` parameter as true. 

**It is false by default**, so if you fetch a quote during extended hours without the parameter, you'll get the quote at closing time.

### Candles
For getting ticker candles, you'll need to specify:
* a ticker symbol
* a resolution (`M`, `D`, `W`, etc. See [docs](https://www.marketdata.app/docs/api/stocks/candles#request-parameters) for a complete list)
* a strategy to specfy a date range. You can use `from` and `to` OR `to` and `countback`.


As an example, for getting candles for last week, for the first strategy:
        
        $ quotes = client.candles("AAPL", "D", (Time.current - 1.week).iso8601, Time.current.iso8601, nil)

and for the second

        $ quotes = client.candles("AAPL", "D", nil, Time.current.iso8601, 7)

`to` and `from` can receive an ISO 8601 compliant utc format or a unix timestamp.

### Bulk candles

For the `bulk_candles` method you pass a array of ticker symbols. Resolution is daily by default, although any daily variation will work as well (like `2D`, `3D`, etc.)

It returns a hashmap with the ticker symbol as a key.

        $ candles = client.bulk_candles(["AAPL", "AMD", "NOTAQUOTE"])

        $ candles["AMD"]
        $ => #<struct MarketData::Models::Candle symbol="AMD", open=174.05, high=174.05, low=169.55, close=171.02, volume=33391035, time=1728446400>
        $ candles["AAPL"]
        $ => #<struct MarketData::Models::Candle symbol="AAPL", open=225.23, high=229.75, low=224.83, close=229.54, volume=31398884, time=1728446400>
        $ candles["NOTAQUOTE"] => nil

If a quote is not found, the hashmap will return a nil value for that ticker's key.

### Earnings

See the API [docs](https://www.marketdata.app/docs/api/stocks/earnings) for parameter specification.

        $ client.earnings("AAPL", from: (Time.now - MarketData::Constants::YEAR).iso8601, to: Time.now.iso8601, countback: nil, report: nil, date: nil)
        $ => [#<struct MarketData::Models::Earning
            symbol="AAPL",
            fiscal_year=2023,
            fiscal_quarter=4,
            date=1696046400,
            report_date=1698897600,
            report_time="after close",
            currency="USD",
            reported_eps=1.46,
            estimated_eps=1.39,
            surprise_eps=0.07,
            surprise_eps_pct=0.0504,
            updated=1728273600>,
            #<struct MarketData::Models::Earning
            symbol="AAPL",
            fiscal_year=2024,
            fiscal_quarter=1,
            ...

## ROADMAP

The following is an ordered list of next expected developments, based on the endpoints present in the [docs](https://www.marketdata.app/docs/api)

From Stocks endpoints:
- [X] Stocks
- [X] Bulk Stocks
- [X] Candles
- [X] Bulk Candles
- [X] Support for new optional parameters for Quotes and Bulk Quotes
- [X] Earnings

From Markets endpoints:
- [ ] Status

From Indices endpoints:
- [ ] Quotes
- [ ] Candles

From Stocks endpoints:
- [ ] Support for optional parameters for Candles
- [ ] Support for optional parameters for Bulk Candles


## Tests

Run tests with

    $ rake 

To run tests and check coverage

    $  rake && open coverage/index.html 
## Contributing

Leave an issue or contact me at sebagonz91@gmail.com

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MarketData project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/market_data/blob/main/CODE_OF_CONDUCT.md).
