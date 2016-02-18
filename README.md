Decanter
===

[![Code Climate](https://codeclimate.com/github/LaunchPadLab/decanter/badges/gpa.svg)](https://codeclimate.com/github/LaunchPadLab/decanter) [![Test Coverage](https://codeclimate.com/github/LaunchPadLab/decanter/badges/coverage.svg)](https://codeclimate.com/github/LaunchPadLab/decanter/coverage)
---


What is Decanter?
---

Decanter is a Rails gem that makes it easy to transform incoming data before it hits the model. The basic idea is that form data entered by a user often needs to be processed before it is stored into the database. A typical example of this is a datepicker. A user selects January 15th, 2015 as the date, but this is going to come into our controller as a string like "01/15/2015", so we need to convert this string to a Ruby Date object before it is stored in our database. Many developers perform this conversion right in the controller, which results in errors and unnecessary complexity, especially as the application grows.

You can think of Decanter as the opposite of Active Model Serializer. Whereas AMS transforms your outbound data into a format that your frontend consumes, Decanter transforms your incoming data into a format that your backend consumes.

Installation
---

```ruby
gem "decanter"
```

```
bundle
```

Add the following to application.rb so we can load your decanters properly:

```
config.paths.add "app/decanter", eager_load: true
config.to_prepare do
  Dir[ File.expand_path(Rails.root.join("app/decanter/**/*.rb")) ].each do |file|
    require_dependency file
  end
end
```

Basic Usage
---

```
rails g decanter Trip name:string start_date:date end_date:date
```

**app/decanter/decanters/trip_decanter.rb**

```ruby
class TripDecanter < Decanter::Base
  input :name, :string
  input :start_date, :date
  input :end_date, :date
end
```

In your controller:

```ruby
  def create
    @trip = Trip.decant_new(params[:trip])

    if @trip.save
      redirect_to trips_path
    else
      render "new"
    end
  end

  def update
    @trip = Trip.find(params[:id])
    
    if @trip.decant_update(params[:trip])
      redirect_to trips_path
    else
      render "new"
    end
  end
```

Or, if you would prefer to get the parsed hash and then do your own logic, you can do the following:

```ruby
def create
  parsed_params = Trip.decant(params[:trip])
  @trip = Trip.new(parsed_params)

  # save logic here
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
    start_date = Date.strptime(params[:trip][:start_date], '%m/%d/%Y')
    end_date = Date.strptime(params[:trip][:end_date], '%m/%d/%Y')
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
  def create
    @trip = Trip.decant_new(params[:trip])

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

Which generates app/decanter/decanters/trip_decanter.rb:

```ruby
class TripDecanter < Decanter::Base
  input :name, :string
  input :start_date, :date
  input :end_date, :date
end
```

You'll also notice that instead of ```@trip = Trip.new(params[:trip])``` we do ```@trip = Trip.decant_new(params[:trip])```. ```decant_new`` is where the magic happens. It is converting the params from this:

```ruby
{ 
  name: "My Trip",
  start_date: "01/15/2015",
  end_date: "01/20/2015"
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

```ruby
class DateParser < Decanter::ValueParser::Base

  allow Date

  parser do |name, value, options|
    parse_format = options.fetch(:parse_format, '%m/%d/%Y')
    ::Date.strptime(value, parse_format)
  end
end
```

```allow Date``` basically tells Decanter that if the value comes in as a Date object, we don't need to parse it at all. Other than that, the parser is really just doing ```Date.strptime("01/15/2015", '%m/%d/%Y')```, which is just a vanilla date parse.

You'll notice that the above ```parser do``` block takes a ```:parse_format``` option. This allows you to specify the format your date string will come in. For example, if you expect "2016-01-15" instead of "01/15/2016", you can adjust the TripDecanter like so:

```ruby
# app/decanter/decanters/trip_decanter.rb

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

**app/decanter/parsers/date_parser**

```ruby
class DateParser < Decanter::ValueParser::Base
  parser do |name, value, options|    
    # your parsing logic here
  end
end
```

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

Which produces app/decanter/decanters/trip and app/decanter/decanters/destination:

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
    @trip = Trip.decant_new(params[:trip])

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

Decanter will work for you non database-backed objects as well. We just need to call ```decant``` to parse our params according to our decanter logic. 

Let's say we have a search filtering object called ```SearchFilter```. We start by generating our decanter:

```
rails g decanter SearchFilter start_date:date end_date:date city:string state:string
```

```ruby
# app/decanter/decanters/search_filter_decanter.rb

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
- datetime
- float
- integer
- phone
- string

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
# app/decanter/squashers/date_squasher.rb

class SquashDateParser < Decanter::Parser::Base
  parser do |name, values, options|
    day, month, year = values.map(&:to_i)
    Date.new(year, month, day)
  end
end
```

No Need for Strong Params
---

Since you are already defining your expected inputs in Decanter, you really don't need strong_params anymore.

In order to tell Decanter to ignore the params not defined in your Decanter, just add the ```strict``` flag to your Decanters:

```ruby
class TripDecanter <  Decanter::Base
  strict true

  input :name
end
```

Or to raise exceptions when parameters arrive in your Decanter that you didn't expect:

```ruby
class TripDecanter <  Decanter::Base
  strict :with_exception

  input :name
end
```
