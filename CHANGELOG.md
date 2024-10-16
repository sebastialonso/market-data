## [Unreleased]

## [0.1.0] - 2024-09-11

- Initial release

## [0.1.1] - 2024-09-12

- Fix handling of snapshot parameter in bulk quotes method
- Rename fetch method to quote on Quote submodule. Quotes methods are no longer wrapped in parent module.

## [0.1.2] - 2024-09-24

- Change validations for bulk_quotes method
- Add `token` method to `Client` class

## [0.2.0] - 2024-09-30

- Internal rework of code. New modules for models, mappers, constants and errors
- Introduced unit tests for almost all modules.
- Introduced coverage. Currently at 85%
- Add functionality for [Candles](https://www.marketdata.app/docs/api/stocks/candles) and [Bulk Candles](https://www.marketdata.app/docs/api/stocks/bulkcandles) endpoints

## [0.2.1] - 2024-10-09

- Fix broken tests
- Add support for new optional parameters for `quotes` and `bulk_quotes` endpoint

## [0.3.0] - 2024-10-09

- Add support for Earnings endpoint under the `earnings` method
- Introduced `Validations` module for parameter validation logic

## [0.4.0] - 2024-10-14

- Add support for Markets status endpoint under the `market_status` method

## [0.5.0] - 2024-10-15

- Add support for Indexes endpoints under `index_quote` and `ìndex_candles`