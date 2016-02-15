Decanter
===

What is Decanter?
---

Decanter is a Rails gem that makes it easy to manipulate form data before it hits the model. The basic idea is that form data entered by a user often needs to be processed before it is stored into the database. A typical example of this is a datepicker. A users selects January 15th, 2015 as the date, but this is going to come in as a string like "01/15/2015", so we need to convert this string into a Ruby Date object before it is stored in our database. Many developers perform this conversion right in the controller, which results in errors and unnecessary complexity, especially as the application grows.

Installation
---

Add Gem:

```ruby
gem "decanter"
```

```
bundle
```

Basic Usage
---

```
rails g decanter Trip name:string start_date:date end_date:date destinations:has_many
```

**app/decanters/trip_decanter.rb**

```ruby
class TripDecanter < Decanter::Base
  input :name, :string
  input :start_date, :date
  input :end_date, :date
  has_many :destinations
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
```

Basic Example
---

We have a form where users can create a new Trip, which has the following attributes: name, start_date, and end_date

Without Decanter, here is what our create action may look like:

```ruby
class TripsController < ApplicationController
  def create
    @trip = Trip.new(trip_params)
    start_date = Date.strptime(trip_params[:start_date], '%m/%d/%Y')
    end_date = Date.strptime(trip_params[:end_date], '%m/%d/%Y')
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

We can see here that converting start_date and end_date to a Ruby date is creating complexity. Could you imagine the complexity involved with performing similar parsing with a deeply nested resource? If you're curious how ugly it would get, we took the liberty of implementing an example here: [Nested Example (Without Decanter)](https://github.com/LaunchPadLab/decanter_demo/blob/master/app/controllers/nested_example/trips_no_decanter_controller.rb)

With Decanter, here is what the same action looks like:

```ruby
class TripsController < ApplicationController
  def create
    @trip = Trip.decant_new(trip_params)

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


That's it! Decanter will take your trip_params which look like:

```ruby
{ 
  name: "My Trip",
  start_date: "01/15/2015",
  end_date: "01/20/2015"
}
```

and convert them to:

```ruby
{ 
  name: "My Trip",
  start_date: Mon, 15 Jan 2015,
  end_date: Mon, 20 Jan 2015
}
```

And then pass these parsed params to Trip.new.

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

If we want more control over the parsing rules for a particular format type, we can create our own parsers.

```
rails g parser Date
```

**app/parsers/date_parser**

```ruby
class DateParser < Decanter::ValueParser::Base
  parser do |name, value, options|    
    # your parsing logic here
  end
end
```
