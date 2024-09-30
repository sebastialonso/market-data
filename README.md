# MarketData

A Ruby wrapper for the [MarketData API](https://www.marketdata.app/docs/api).

## Installation

    $ gem install market_data
    $ bundle install

## Usage

    $ client = MarketData.Client.new "YOUR_API_TOKEN"
    $ client.quote("AAPL")
    $ => <struct MarketData::Models::Quote symbol="AAPL", ask=231.42, askSize=2, bid=231.4, .....

## ROADMAP

The following is an ordered list of next expected developments, based on the endpoints present in the [docs](https://www.marketdata.app/docs/api)

From Stocks endpoints:
- [X] Stocks
- [X] Bulk Stocks
- [X] Candles
- [X] Bulk Candles
- [X] Support for optional parameters for Bulk Candles
- [] Earnings

From Markets endpoints:
- [] Status

From Indices endpoints:
- [] Quotes
- [] Candles

From Stocks endpoints:
- [] Support for optional parameters for Candles
- [] Support for optional parameters for Bulk Candles


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
