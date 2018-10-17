Decanter
===

[![Code Climate](https://codeclimate.com/github/LaunchPadLab/decanter/badges/gpa.svg?ignore=me)](https://codeclimate.com/github/LaunchPadLab/decanter) [![Test Coverage](https://codeclimate.com/github/LaunchPadLab/decanter/badges/coverage.svg?ignore=me)](https://codeclimate.com/github/LaunchPadLab/decanter/coverage)
---


What is Decanter?
---

Decanter is a Rails gem that makes it easy to transform incoming data before it hits the model. The basic idea is that form data entered by a user often needs to be processed before it is stored into the database. A typical example of this is a datepicker. A user selects January 15th, 2015 as the date, but this is going to come into our controller as a string like "15/01/2015", so we need to convert this string to a Ruby Date object before it is stored in our database. Many developers perform this conversion right in the controller, which results in errors and unnecessary complexity, especially as the application grows.

You can think of Decanter as the opposite of Active Model Serializer. Whereas AMS transforms your outbound data into a format that your frontend consumes, Decanter transforms your incoming data into a format that your backend consumes.

Installation
---

```ruby
gem "decanter"
```

```
bundle
```

Basic Usage
---

```
rails g decanter Trip name:string start_date:date end_date:date
```

**app/decanters/trip_decanter.rb**

```ruby
class TripDecanter < Decanter::Base
  input :name, :string
  input :start_date, :date
  input :end_date, :date
end
```

By default, Decanter will use the [default parser](https://github.com/LaunchPadLab/decanter#default-parsers) that matches your input data type.

```ruby
  input :name, :string #=> StringParser
```

To reference a custom or modified parser,

```ruby
  input :name, :string, :custom_string_parser
```

In your controller:

```ruby
  include Decanter::Decant

  def create
    @trip = Trip.new(decant(:trip, params[:trip]))

    if @trip.save
      redirect_to trips_path
    else
      render "new"
    end
  end

  def update
    @trip = Trip.find(params[:id])

    if @trip.update(decant(:trip, params[:trip]))
      redirect_to trips_path
    else
      render "new"
    end
  end
```

Basic Example
---

We have a form where users can create a new Trip, which has the following attributes: name, start_date, and end_date

Without Decanter, here is what our create action may look like:

```ruby
class TripsController < ApplicationController
  def create
    @trip = Trip.new(params[:trip])
    start_date = Date.strptime(params[:trip][:start_date], '%d/%m/%Y')
    end_date = Date.strptime(params[:trip][:end_date], '%d/%m/%Y')
    @trip.start_date = start_date
    @trip.end_date = end_date

    if @trip.save
      redirect_to trips_path
    else
      render 'new'
    end
  end
end
```

We can see here that converting start_date and end_date to a Ruby date is creating complexity. Could you imagine the complexity involved with performing similar parsing with a nested resource? If you're curious how ugly it would get, we took the liberty of implementing an example here: [Nested Example (Without Decanter)](https://github.com/LaunchPadLab/decanter_demo/blob/master/app/controllers/nested_example/trips_no_decanter_controller.rb)

With Decanter installed, here is what the same controller action would look like:

```ruby
class TripsController < ApplicationController

  include Decanter::Decant

  def create
    @trip = Trip.new(decant(:trip, params[:trip]))

    if @trip.save
      redirect_to trips_path
    else
      render 'new'
    end
  end
end
```

As you can see, we no longer need to parse the start and end date. Let's take a look at how we accomplished that.

From terminal we ran:

```
rails g decanter Trip name:string start_date:date end_date:date
```

Which generates app/decanters/trip_decanter.rb:

```ruby
class TripDecanter < Decanter::Base
  input :name, :string
  input :start_date, :date
  input :end_date, :date
end
```

You'll also notice that instead of ```@trip = Trip.new(params[:trip])``` we do ```@trip = Trip.new(decant(:trip, params[:trip]))```. ```decant``` is where the magic happens. It is converting the params from this:

```ruby
{
  name: "My Trip",
  start_date: "15/01/2015",
  end_date: "20/01/2015"
}
```

to this:

```ruby
{
  name: "My Trip",
  start_date: Mon, 15 Jan 2015,
  end_date: Mon, 20 Jan 2015
}
```

As you can see, the converted params hash has converted start_date and end_date to a Ruby Date object that is ready to be stored in our database.

Adding Custom Parsers
---

In the above example, start_date and end_date are ran through a DateParser that lives in Decanter. Let's take a look at the DateParser:

** Note this changed in version 0.7.2. Now parser must inherit from Decanter::Parser::ValueParser or Decanter::Parser::HashParser instead of Decanter::Parser::Base **

```ruby
class DateParser < Decanter::Parser::ValueParser

  allow Date

  parser do |value, options|
    if (parse_format = options[:parse_format])
      ::Date.strptime(value, parse_format)
    else
      ::Date.parse(value)
    end
  end
end
```

```allow Date``` basically tells Decanter that if the value comes in as a Date object, we don't need to parse it at all. Other than that, the parser is really just doing ```Date.parse('15/01/2015')```, which is just a vanilla date parse.

You'll notice that the above ```parser do``` block takes a ```:parse_format``` option. This allows you to specify the format your date string will come in. For example, if you expect "2015-01-15" instead of "15/01/2015", you can adjust the TripDecanter like so:

```ruby
# app/decanters/trip_decanter.rb

class TripDecanter < Decanter::Base
  input :name, :string
  input :start_date, :date, parse_format: '%Y-%m-%d'
  input :end_date, :date, parse_format: '%Y-%m-%d'
end
```

You can add your own parser if you want more control over the logic, or if you have a peculiar format type we don't support.

```
rails g parser Date
```

**lib/decanter/parsers/date_parser**

```ruby
class DateParser < Decanter::Parser::ValueParser
  parser do |value, options|
    # your parsing logic here
  end
end
```


By inheriting from Decanter::Parser::ValueParser, the assumption is that the value returned from the parser will be the value associated with the provided key. If you need more control over the result, for example, you want a parser that returns multiple key value pairs, you should instead inherit from Decanter::Parser::HashParser. This requires that the value returned is a hash. For example:

```ruby
class KeyValueSplitterParser < Decanter::Parser::HashParser
  ITEM_DELIM = ','
  PAIR_DELIM = ':'

  parser do |name, val, options|
    # val = 'color:blue,price:45.31'

    item_delimiter = options.fetch(:item_delimiter, ITEM_DELIM)
    pair_delimiter = options.fetch(:pair_delimiter, PAIR_DELIM)

    pairs = val.split(item_delimiter) # ['color:blue', 'price:45.31']

    hash = {}
    pairs.each do |pair|
      key, value = pair.split(pair_delimiter) # 'color', 'blue'
      hash[key] = value
    end
    return hash
  end
end
```

The ```parser``` block takes the 'name' as an additional argument and must return a hash.

Nested Example
---

Let's say we have two models in our app: a Trip and a Destination. A trip has many destinations, and is prepared to accept nested attributes from the form.

```ruby
# app/models/trip.rb

class Trip < ActiveRecord::Base
  has_many :destinations
  accepts_nested_attributes_for :destinations
end
```

```ruby
# app/models/destination.rb

class Destination < ActiveRecord::Base
  belongs_to :trip
end
```

First, let's create our decanters for Trip and Destination. Note: decanters are automatically created whenever you run ```rails g resource```.

```
rails g decanter Trip name destinations:has_many
rails g decanter Destination city state arrival_date:date departure_date:date
```

Which produces app/decanters/trip and app/decanters/destination:

```ruby
class TripDecanter < Decanter::Base
  input :name, :string
  has_many :destinations
end
```

```ruby
class DestinationDecanter < Decanter::Base
  input :city, :string
  input :state, :string
  input :arrival_date, :date
  input :departure_date, :date
end
```

With that, we can use the same vanilla create action syntax you saw in the basic example above:

```ruby
class TripsController < ApplicationController
  def create
    @trip = Trip.new(decant(:trip, params[:trip]))

    if @trip.save
      redirect_to trips_path
    else
      render 'new'
    end
  end
end
```

Each of the destinations in our params[:trip] are automatically parsed according to the DestinationDecanter inputs set above. This means that ```arrival_date``` and ```departure_date``` are converted to Ruby Date objects for each of the destinations passed through the nested params. Yeehaw!

Non Database-Backed Objects
---

Decanter will work for your non database-backed objects as well. We just need to call ```decant``` to parse our params according to our decanter logic.

Let's say we have a search filtering object called ```SearchFilter```. We start by generating our decanter:

```
rails g decanter SearchFilter start_date:date end_date:date city:string state:string
```

```ruby
# app/decanters/search_filter_decanter.rb

class SearchFilterDecanter < Decanter::Base

end
```

```ruby
# app/controllers/search_controller.rb

def search
  decanted_params = SearchFilterDecanter.decant(params[:search])
  # decanted_params is now parsed according to the parsers defined
  # in SearchFilterDecanter
end
```

Default Parsers
---

Decanter comes with the following parsers:
- boolean
- date
- date_time
- float
- integer
- join
- key_value_splitter
- pass
- phone
- string
- time

As an example as to how these parsers differ, let's consider ```float```. The float parser will perform a regex to find only characters that are digits or decimals. By doing that, your users can enter in commas and currency symbols without your backend throwing a hissy fit.

We encourage you to create your own parsers for other needs in your app, or generate one of the above listed parsers to override its behavior.

```
rails g parser Zip
```

Squashing Inputs
---

Sometimes, you may want to take several inputs and combine them into one finished input prior to sending to your model. For example, if day, month, and year come in as separate parameters, but your database really only cares about start_date.

```ruby
class TripDecanter < Decanter::Base
  input [:day, :month, :year], :squash_date, key: :start_date
end
```

```
rails g parser SquashDate
```

```ruby
# lib/decanter/parsers/squash_date_parser.rb

class SquashDateParser < Decanter::Parser::ValueParser
  parser do |values, options|
    day, month, year = values.map(&:to_i)
    Date.new(year, month, day)
  end
end
```

Chaining Parsers
---

Parsers are composable! Suppose you want a parser that takes an incoming percentage like "50.3%" and converts it into a float for your database like .503. You could implement this with:

```ruby
class PercentParser < Decanter::Parser::ValueParser
  REGEX = /(\d|[.])/

  parser do |val, options|
    my_float = val.scan(REGEX).join.try(:to_f)
    my_float / 100 if my_float
  end
end
```

This works, but it duplicates logic that already exists in `FloatParser`. Instead, you can specify a parser that should always run before your parsing logic, then you can assume that your parser receives a float:

```ruby
class SmartPercentParser < Decanter::Parser::ValueParser

  pre :float

  parser do |val, options|
    val / 100
  end
end
```

If a preparser returns nil or an empty string, subsequent parsers will not be called, just like normal!

This can also be achieved by providing multiple parsers in your decanter:

```ruby
class SomeDecanter < Decanter::Base
  input :some_percent, [:float, :percent]
end
```

No Need for Strong Params
---

Since you are already defining your expected inputs in Decanter, you really don't need strong params anymore.

Note: starting with version 0.7.2, the default strict mode is ```:with_exception```. You can modify your default strict mode in your configuration file (see the "Configuration" section below).

#### Mode: with_exception (default mode)

To raise exceptions when parameters arrive in your Decanter that you didn't expect:

```ruby
class TripDecanter <  Decanter::Base
  strict :with_exception

  input :name
end
```

#### Mode: strict

In order to tell Decanter to ignore the params not defined in your Decanter, just add the ```strict``` flag to your Decanters:

```ruby
class TripDecanter <  Decanter::Base
  strict true

  input :name
end
```

#### Requiring Params

If you provide the option `:required` for an input in your decanter, an exception will be thrown if the parameters is nil or an empty string.

```ruby
class TripDecanter <  Decanter::Base
  input :name, :string, required: true
end
```

#### Ignoring Params

If you anticipate your decanter will receive certain params that you simply want to ignore and therefore do not want Decanter to raise an exception, you can do so by calling the `ignore` method:

```ruby
class TripDecanter <  Decanter::Base
  ignore :created_at, :updated_at

  input :name, :string
end
```

Configuration
---

You can generate a local copy of the default configuration with ```rails generate decanter:install```. This will create the initializer ```../config/initializers/decanter.rb```.

Starting with version 0.7.2, the default strict mode is ```:with_exception```. If this is what you prefer, you no longer have to set it in every decanter. You can still set this on individual decanters or you can configure it globally in the initializer:

```ruby
# ../config/initializers/decanter.rb

Decanter.config do |config|
  config.strict = true
end

# Or

Decanter.configuration.strict = true
```

Likewise, you can put the above code in a specific environment configuration.

Decanter Exceptions
---

 - MissingRequiredInputValue

  Raised when required inputs have been enabled, but provided arguments to `decant()` do not contain values for those required inputs.

 - UnhandledKeysError

  Raised when there are unhandled keys.

Changes from 1.1.x
------------------

Previously it was possible to call `Trip.decant_new(params[:trip])`.  This has been removed by default, but it is possible to include it by adding the following to the classes where you want them.

```
class Trip < ActiveRecord::Base
  include Decanter::Extensions

  # ... rest of class goes here ... #
end
```

This adds '#decanter_new', '#decanter_create', '#decanter_create!', '#decanter_update', '#decanter_update!', and `#decant` to your model, allowing you to use the gem in the existing style.


