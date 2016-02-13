ParamsTransformer
===

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

Create a class to process your form and have it inherit from ParamsTransformer::Base. I typically create the following folder to hold my form classes: app/classes/forms

**app/classes/forms/property.rb**

```ruby
class Forms::Property < ParamsTransformer::Base

  input :bedrooms, :integer
  input :price, :float
  input :has_air_conditioning, :boolean
  input :has_parking, :boolean
  input :has_laundry, :boolean

end
```

In your controller:

```ruby
  def create
    @form = Forms::Property.new(params)

    if @form.save
      redirect_to trips_path
    else
      set_index_variables
      render "index"
    end
  end
```

Inheritance
---

General pattern:

- forms/property.rb
- forms/property/create.rb (inherits from forms/property.rb)
- forms/property/update.rb (inherits from forms/property.rb)


```ruby
# app/classes/forms/property.rb
class Forms::Property < ParamsTransformer::Base

  input :bedrooms, :integer
  input :price, :float
  input :referred_by, :string

end


# app/classes/forms/property/create.rb
class Forms::Property::Create < Forms::Property

  # override any input, validation, or method here

end
```

class Forms::Property::Update < Forms::Property

  # override any input, validation, or method here

end
```

Associations
---

Let's say we are creating a web app where teacher's can create Courses with assignments and resources attached to the courses.

The modeling would look like:

class Course < ActiveRecord::Base

  has_many :assignments
  has_many :resources

end



Why a Library for Parsing Forms?
---

In my humble opinion, Rails is missing a tool for parsing forms on the backend. Currently the process looks something like this:

```html
# new.html.erb
<%= form_for @trip do |trip_builder| %>
  <div class="field">
    <%= trip_builder.label :miles %>
    <%= trip_builder.text_field :miles, placeholder: '50 miles' %>
  </div>
<% end %>
```

```ruby
  # trips_controller

  def create
    @trip = Trip.new(trip_params)

    if @trip.save
      redirect_to trips_path, notice: "New trip successfully created."
    else
      render "new"
    end
  end
```

The problem with this approach is that there is nothing that processes the user inputs before being saved into the database. For example, if the user types "1,000 miles" into the form, Rails would store 0 instead of 1000 into our "miles" column.

The "Services" concept that many Rails developers favor is on point. Every form should have a corresponding Ruby class whose responsibility is to process the inputs and get the form ready for storage.

However, this "Services" concept does not have a supporting framework. It is repetitive for every developer, for example, to write code to parse a decimal field that comes into our Ruby controller as a string (as in the example above).

Here is how it may be done right now:

```ruby
class Forms::Trip

  attr_accessor :trip

  def initialize(args = {})
    @trip = Trip.new
    @trip.miles = parse_miles(args[:miles)
  end

  def parse_miles(miles_input)
    regex = /(\d|[.])/ # only care about numbers and decimals
    miles_input.scan(regex).join.try(:to_f)
  end

  def save
    @trip.save
  end

end
```

```ruby
  # trips_controller.rb

  def create
    form = Forms::Trip.new(trip_params)
    @trip = form.trip

    if form.save
      redirect_to trips_path, notice: "New trip successfully created."
    else
      render "new"
    end
  end
```

While this process is not so bad with only one field and one model, it gets more complex with many different fields, types of inputs, and especially with nested attributes.

A better solution is to have the form service classes inherit from a base "form parser" class that can handle the common parsing needs of the community. For example:

```ruby
class Forms::Trip < FormParse::Base

  input :miles, :float

  def after_init(args)
    @trip = Trip.new(to_hash)
  end

end
```

```ruby
  # trips_controller.rb
  # same as above

  def create
    form = Forms::Trip.new(trip_params)
    @trip = form.trip

    if form.save
      redirect_to trips_path, notice: "New trip successfully created."
    else
      render "new"
    end
  end
```

The FormParse::Base class that Forms::Trip inherits from by default performs the proper regex as seen in the original Forms::Trip service object above. We need only define the input key and the type of input and the base class takes care of the heavy lifting.

The "to_hash" method takes the inputs and converts the parsed values into a hash, which produces the following in this case:

```ruby
  { miles: 1000.0 }
```

A more complex form would end up with a service class like below:

```ruby
class Forms::Trip

  attr_accessor :trip

  def initialize(args = {})
    @trip = Trip.new
    @trip.miles = parse_miles(args[:miles)
    @trip.origin_city = args[:origin_city]
    @trip.origin_state = args[:origin_state]
    @trip.departure_datetime = parse_datetime(args[:departure_datetime])
    @trip.destination_city = args[:destination_city]
    @trip.destination_state = args[:destination_state]
    @trip.arrival_datetime = parse_datetime(args[:arrival_datetime])
  end

  def parse_miles(miles_input)
    regex = /(\d|[.])/ # only care about numbers and decimals
    miles_input.scan(regex).join.try(:to_f)
  end

  def parse_datetime(datetime_input)
    Date.strptime(datetime, "%m/%d/%Y")
  end

  def save
    @trip.save
  end

end
```

With a framework, it would only involve the following:

```ruby
class Forms::Trip < FormParse::Base

  input :miles, :float
  input :origin_city, :string
  input :origin_state, :string
  input :departure_datetime, :datetime
  input :destination_city, :string
  input :destination_state, :string
  input :arrival_datetime, :datetime

  def after_init(args)
    @trip = Trip.new(to_hash)
  end

  # to_hash produces:
  # {
  #   miles: 1000.0,
  #   origin_city: "Chicago",
  #   origin_state: "IL",
  #   departure_datetime: # DateTime object
  #   destination_city: "New York",
  #   destination_state: "NY",
  #   arrival_datetime: # DateTime object
  # }

end
```

Taking it a step further, if our form inputs are not database backed, we can even validate within our new service object like so:

```ruby
class FormParse::Base
  include ActiveModel::Model

  # ... base parsing code
end

class Form::Trip < FormParse::Base

  input :miles, :float
  input :origin_city, :string
  input :origin_city, :string
  input :destination_city, :string
  input :destination_state, :string

  validates :miles, :origin_city, :origin_state, :destination_city, :destination_state, presence: true

  def after_init(args)
    @trip = Trip.new(to_hash)
  end

  def save
    if valid? && trip.valid?
      trip.save
    else
      return false
    end
  end

end
```

Of course, the save method could be abstracted to our base class too, assuming we define which object the Form::Trip class is saving like so:

```ruby
class Form::Trip

  def object
    trip
  end

  # ... above code here
end

class FormParse::Base

  def save
    if valid? && object.valid?
      object.save
    else
      return false
    end
  end
end

```

But where we really can see benefits from a "framework" for parsing our Rails forms is when we start to use nested attributes. For example, if we abstract the origin and destination fields to a "Location" model, we could build out a separate service class to handle parsing our "Location" form (even if it is in the context of a parent object like Trip).

```ruby
class Forms::Location < FormParse::Base

  input :city, :string
  input :state, :string
  input :departure_datetime, :datetime
  input :arrival_datetime, :datetime

  validates :city, :state :presence => true

end

class Forms::Trip < FormParse::Base

  input :miles, :float
  input :origin_attributes, :belongs_to, class: 'location'
  input :destination_attributes, :belongs_to, class: 'location'

  validates :miles, presence: true

  def after_init(args)
    @trip = Trip.new(to_hash)
  end
end
```

The FormParse::Base class will recoginze the :belongs_to relationship and utilize the Location service class to parse the part of the params hash that correspond with our destination and origin models. This is great because if there is anywhere that the user can update just the origin or destination of the trip, we could just reuse that Location service object to parse the form.
