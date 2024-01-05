# Decanter

Decanter is a Ruby gem that makes it easy to transform incoming data before it hits the model. You can think of Decanter as the opposite of Active Model Serializers (AMS). While AMS transforms your outbound data into a format that your frontend consumes, Decanter transforms your incoming data into a format that your backend consumes.

```ruby
gem 'decanter', '~> 4.0'
```

## Migration Guides

- [v3.0.0](migration-guides/v3.0.0.md)

## Contents

- [Basic Usage](#basic-usage)
  - [Decanters](#decanters)
  - [Generators](#generators)
  - [Decanting Collections](#decanting-collections)
  - [Nested resources](#nested-resources)
  - [Default parsers](#default-parsers)
  - [Parser options](#parser-options)
  - [Exceptions](#exceptions)
- [Advanced usage](#advanced-usage)
  - [Custom parsers](#custom-parsers)
  - [Squashing inputs](#squashing-inputs)
  - [Chaining parsers](#chaining-parsers)
  - [Requiring params](#requiring-params)
  - [Global configuration](#global-configuration)
- [Contributing](#contributing)

## Basic Usage

### Decanters

Declare a `Decanter` for a model:

```ruby
# app/decanters/trip_decanter.rb

class TripDecanter < Decanter::Base
  input :name, :string
  input :start_date, :date
  input :end_date, :date
end
```

Then, transform incoming params in your controller using `Decanter#decant`:

```rb
# app/controllers/trips_controller.rb

  def create
    trip_params = params.require(:trip) # or params[:trip] if you are not using Strong Parameters
    decanted_trip_params = TripDecanter.decant(trip_params)
    @trip = Trip.new(decanted_trip_params)

    # ...any response logic
  end

```

### Generators

Decanter comes with generators for creating `Decanter` and `Parser` files:

```
rails g decanter Trip name:string start_date:date end_date:date
```

```
rails g parser TruncatedString
```

### Decanting Collections

Decanter can decant a collection of a resource, applying the patterns used in the [fast JSON API gem](https://github.com/Netflix/fast_jsonapi#collection-serialization):

```rb
# app/controllers/trips_controller.rb

  def create
    trip_params = {
      trips: [
        { name: 'Disney World', start_date: '12/24/2018', end_date: '12/28/2018' },
        { name: 'Yosemite', start_date: '5/1/2017', end_date: '5/4/2017' }
      ]
    }
    decanted_trip_params = TripDecanter.decant(trip_params[:trips])
    Trip.create(decanted_trip_params) # bulk create trips with decanted params
  end
```

#### Control Over Decanting Collections

You can use the `is_collection` option for explicit control over decanting collections.

`decanted_trip_params = TripDecanter.decant(trip_params[:trips], is_collection: true)`

If this option is not provided, autodetect logic is used to determine if the providing incoming params holds a single object or collection of objects.

- `nil` or not provided: will try to autodetect single vs collection
- `true` will always treat the incoming params args as *collection*
- `false` will always treat incoming params args as *single object*
- `truthy` will raise an error

### Nested resources

Decanters can declare relationships using `ActiveRecord`-style declarators:

```ruby
class TripDecanter < Decanter::Base
  has_many :destinations
end
```

This decanter will look up and apply the corresponding `DestinationDecanter` whenever necessary to transform nested resources.

### Default parsers

Decanter comes with the following parsers out of the box:

- `:boolean`
- `:date`
- `:date_time`
- `:float`
- `:integer`
- `:pass`
- `:phone`
- `:string`
- `:array`

Note: these parsers are designed to operate on a single value, except for `:array`. This parser expects an array, and will use the `parse_each` option to call a given parser on each of its elements:

```ruby
input :ids, :array, parse_each: :integer
```

### Parser options

Some parsers can receive options that modify their behavior. These options are passed in as named arguments to `input`:

**Example:**

```ruby
input :start_date, :date, parse_format: '%Y-%m-%d'
```
**Available Options:**
| Parser      | Option      | Default    | Notes
| ----------- | ----------- | -----------| -----------
| `ArrayParser`   | `parse_each`| N/A | Accepts a parser type, then uses that parser to parse each element in the array. If this option is not defined, each element is simply returned.
| `DateParser`| `parse_format` | `'%m/%d/%Y'`| Accepts any format string accepted by Ruby's `strftime` method
| `DateTimeParser` | `parse_format` | `'%m/%d/%Y %I:%M:%S %p'` | Accepts any format string accepted by Ruby's `strftime` method

### Exceptions

By default, `Decanter#decant` will raise an exception when unexpected parameters are passed. To override this behavior, you can change the strict mode option to one of:

- `true` (default): unhandled keys will raise an unexpected parameters exception
- `false`: all parameter key-value pairs will be included in the result
- `:ignore`: unhandled keys will be excluded from the decanted result

```ruby
class TripDecanter <  Decanter::Base
  strict false
  # ...
end
```

Or explicitly ignore a key:

```rb
class TripDecanter <  Decanter::Base
  ignore :created_at, :updated_at
  # ...
end
```

You can also disable strict mode globally using a [global configuration](#global-configuration) setting.

## Advanced Usage

### Custom Parsers

To add a custom parser, first create a parser class:

```rb
# app/parsers/truncate_string_parser.rb
class TruncateStringParser < Decanter::Parser::ValueParser

  parser do |value, options|
    length = options.fetch(:length, 100)
    value.truncate(length)
  end
end
```

Then, use the appropriate key to look up the parser:

```ruby
  input :name, :truncate_string #=> TruncateStringParser
```

#### Custom parser methods

- `#parse <block>`: (required) recieves a block for parsing a value. Block parameters are `|value, options|` for `ValueParser` and `|name, value, options|` for `HashParser`.
- `#allow [<class>]`: skips parse step if the incoming value `is_a?` instance of class(es).
- `#pre [<parser>]`: applies the given parser(s) before parsing the value.

#### Custom parser base classes

- `Decanter::Parser::ValueParser`: subclasses are expected to return a single value.
- `Decanter::Parser::HashParser`: subclasses are expected to return a hash of keys and values.

### Squashing inputs

Sometimes, you may want to take several inputs and combine them into one finished input prior to sending to your model. You can achieve this with a custom parser:

```ruby
class TripDecanter < Decanter::Base
  input [:day, :month, :year], :squash_date, key: :start_date
end
```

```ruby
class SquashDateParser < Decanter::Parser::ValueParser
  parser do |values, options|
    day, month, year = values.map(&:to_i)
    Date.new(year, month, day)
  end
end
```

### Chaining parsers

You can compose multiple parsers by using the `#pre` method:

```ruby
class FloatPercentParser < Decanter::Parser::ValueParser

  pre :float

  parser do |val, options|
    val / 100
  end
end
```

Or by declaring multiple parsers for a single input:

```ruby
class SomeDecanter < Decanter::Base
  input :some_percent, [:float, :percent]
end
```

### Requiring params

If you provide the option `:required` for an input in your decanter, an exception will be thrown if the parameter is `nil` or an empty string.

```ruby
class TripDecanter <  Decanter::Base
  input :name, :string, required: true
end
```

_Note: we recommend using [Active Record validations](https://guides.rubyonrails.org/active_record_validations.html) to check for presence of an attribute, rather than using the `required` option. This method is intended for use in non-RESTful routes or cases where Active Record validations are not available._


### Default values

If you provide the option `:default_value` for an input in your decanter, the input key will be initialized with the given default value. Input keys not found in the incoming data parameters will be set to the provided default rather than ignoring the missing key. Note: `nil` and empty keys will not be overridden.

```ruby
class TripDecanter <  Decanter::Base
  input :name, :string
  input :destination, :string, default_value: 'Chicago'
end

```

```
TripDecanter.decant({ name: 'Vacation 2020' })
=> { name: 'Vacation 2020', destination: 'Chicago' }

```

### Global configuration

You can generate a local copy of the default configuration with `rails generate decanter:install`. This will create an initializer where you can do global configuration:

Setting strict mode to :ignore will log out any unhandled keys. To avoid excessive logging, the global configuration can be set to `log_unhandled_keys = false`

```ruby
# ./config/initializers/decanter.rb

Decanter.config do |config|
  config.strict = false
  config.log_unhandled_keys = false
end
```

## Contributing

This project is maintained by developers at [LaunchPad Lab](https://launchpadlab.com/). Contributions of any kind are welcome!

We aim to provide a response to incoming issues within 48 hours. However, please note that we are an active dev shop and these responses may be as simple as _"we do not have time to respond to this right now, but can address it at {x} time"_.

For detailed information specific to contributing to this project, reference our [Contribution guide](CONTRIBUTING.md).
