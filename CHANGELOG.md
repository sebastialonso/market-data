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