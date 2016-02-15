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

Create a class to process your form and have it inherit from Decanter::Base. I typically create the following folder to hold my form classes: app/classes/forms

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

