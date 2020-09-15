# Decanter

Decanter is a Ruby gem that makes it easy to transform incoming data before it hits the model. You can think of Decanter as the opposite of Active Model Serializers (AMS). While AMS transforms your outbound data into a format that your frontend consumes, Decanter transforms your incoming data into a format that your backend consumes.

```ruby
gem 'decanter', '~> 3.0'
```

## Migration Guides

- [v3.0.0](migration-guides/v3.0.0.md)

## Contents

- [Basic Usage](#basic-usage)
  - [Decanters](#decanters)
  - [Generators](#generators)
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

Parsers can receive options that modify their behavior. These options are passed in as named arguments to `input`:

```ruby
input :start_date, :date, parse_format: '%Y-%m-%d'
```

### Exceptions

By default, `Decanter#decant` will raise an exception when unexpected parameters are passed. To override this behavior, you can disable strict mode:

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

If you provide the option `:default_value` for an input in your decanter, the input key will be initialized with the given default value. Input keys not found in the incoming data parameters will be set to the provided default rather than ignoring the missing key.

```ruby
class TripDecanter <  Decanter::Base
  input :some_boolean, :boolean, default_value: true
end
```

### Global configuration

You can generate a local copy of the default configuration with `rails generate decanter:install`. This will create an initializer where you can do global configuration:

```ruby
# ./config/initializers/decanter.rb

Decanter.config do |config|
  config.strict = false
end
```

## Contributing

This project is maintained by developers at [LaunchPad Lab](https://launchpadlab.com/). Contributions of any kind are welcome!

We aim to provide a response to incoming issues within 48 hours. However, please note that we are an active dev shop and these responses may be as simple as _"we do not have time to respond to this right now, but can address it at {x} time"_.

For detailed information specific to contributing to this project, reference our [Contribution guide](CONTRIBUTING.md).
