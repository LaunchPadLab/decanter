# Decanter Gem Changelog

## 1.2.0 (17 October 2018)
  * Refactored Parser#parse not to require the name option (!9)
  * Refactored Decanter::Core#parse (!9)
  * Removed `_new`, `_update` etc calls from models, replacing them with a
    `decant` method which can be called from with a controller, if
    `Decanter::Decant` is included. (!1)
  * Added TimeParser, clarified DateParser, DateTimeParser (!5)
  * Altered `FloatParser` and `IntegerParser` to use `Float()` and `Integer()`
    respectively (#1,!7)
  * Fixed JoinParser to obey delimiter parameter (!6)
  * Applied Bytemark house-style Rubocop (!2, !3)
  * Gem bumps: decanter (1.1.8 to 1.2.0),
               actionpack (5.1.4 to 5.2.1),
               actionview (5.1.4 to 5.2.1),
               activesupport (5.1.4 to 5.2.1),
               crass (1.0.3 to 1.0.4),
               docile (1.1.5 to 1.3.1),
               dotenv (2.2.1 to 2.5.0),
               erubi (1.7.0 to 1.7.1),
               i18n (0.9.3 to 1.1.1),
               loofah (2.1.1 to 2.2.2),
               nokogiri (1.8.2 to 1.8.5),
               rack (2.0.4 to 2.0.5),
               rack-test (0.8.2 to 1.1.0),
               rails-html-sanitizer (1.0.3 to 1.0.4),
               railties (5.1.4 to 5.2.1),
               rake (10.5.0 to 12.3.2),
               rspec-core (3.7.1 to 3.8.0),
               rspec-expectations (3.7.0 to 3.8.2),
               rspec-mocks (3.7.0 to 3.8.0),
               rspec-rails (3.7.2 to 3.8.0),
               rspec-support (3.7.1 to 3.8.0),
               simplecov (0.15.1 to 0.16.1)
