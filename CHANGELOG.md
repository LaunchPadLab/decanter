# Decanter Gem Changelog

## 2.0.0 (09 January 2019)
  * Refactored `Core#input`, `Core#has_one`, `Core#has_many` to call a new
    method `handler` which sets all options, allowing assoiactive handlers to
    be marked required.
  * Added tests that reflect the examples in the README.
  * Refactored `Core#handle_input`, `Core#handle_association`,
    `Core#handle_has_one`, and `Core#handle_has_many` into one, simple
    `Core#handle` method.
  * Removed unecessary rescue for `constantize` in `Decanter#decanter_from` and
    `Decanter#decanter_for`, as it raises a NameError anyway.
  * Refactored Parser#parse not to require the name option
  * Refactored Decanter::Core#parse
  * Removed `_new`, `_update` etc calls from models, replacing them with a
    `decant` method which can be called from with a controller, if
    `Decanter::Decant` is included.
  * Added TimeParser, clarified DateParser, DateTimeParser
  * Altered `FloatParser` and `IntegerParser` to use `Float()` and `Integer()`
    respectively
  * Fixed JoinParser to obey delimiter parameter
  * Gem bumps: decanter (1.1.9 to 2.0.0),
               actionpack (5.1.4 to 5.2.1),
               actionview (5.1.4 to 5.2.1),
               activesupport (5.1.4 to 5.2.1),
               docile (1.1.5 to 1.3.1),
               dotenv (2.2.1 removed),
               erubi (1.7.0 to 1.7.1),
               i18n (0.9.3 to 1.1.1),
               rack (2.0.4 to 2.0.5),
               rack-test (0.8.2 to 1.1.0),
               railties (5.1.4 to 5.2.1),
               rake (10.5.0 to 12.3.1),
               rspec-core (3.7.1 to 3.8.0),
               rspec-expectations (3.7.0 to 3.8.2),
               rspec-mocks (3.7.0 to 3.8.0),
               rspec-rails (3.7.2 to 3.8.0),
               rspec-support (3.7.1 to 3.8.0),
               simplecov (0.15.1 to 0.16.1)
