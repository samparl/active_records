# Objectify

## Introduction
#### What is it?
Objectify is a Ruby library written to facilitate object oriented development (object-relational mapping, or ORM). Using Objectify, developers can treat relational databases and their contents as objects, allowing more a more Ruby-like development experience.

Find out more about the other on his [homepage](http://samaparl.com),
[LinkedIn](https://www.linkedin.com/in/sam-parl-6a3a4040)
or [AngelList](https://angel.co/samuel-parl).

##### Relational records - in Ruby!
```ruby
# Get information about your table, including table and column names

class House < SQLObject
end

House.finalize!

House.table_name
  # => :houses

::columns
House.columns
  # => [:id, :owner_id, :address]
```
```ruby
# Find individual records by their id or by their attributes
House.find(1) # => <House:0x007ffe4c8eaaa8 @attributes={:id=>1, :address=>"1 Main St"}>

House.where(address: "1 Main St") # => <House:0x007ffe4c8eaaa8 @attributes={:id=>1, :address=>"1 Main St"}>

# Find all records
House.all
  # => [
    <House:0x007ffe4c8eaaa8 @attributes={:id=>1, :address=>"1 Main St", :owner_id=>3}>,
    <House:0x034ffe3c0e4a38 @attributes={:id=>2, :address=>"3 Pine St", :owner_id=>3}>
  ]
# Stage records before saving them to the database
home = House.new(address: "7 Grove Ave", owner_id: 1)

# Save staged records to the database
home.save

# Update records on the spot
home.update(address: "3 Maple Blvd")
```
##### Associations between classes
```ruby
class House < SQLObject
  belongs_to :owner
  has_one_through :occupying_family, :owner, :family
end

House.finalize!

class Owner < SQLObject
  has_many :houses
  belongs_to :family
end

Owner.finalize!

home = House.find(3)
home.owner
  # => <Owner:0x007err483f32dk @attributes={:id=>1, :name=>"Peter Macdougal", :family_id=>2}>
```
N.B. the `has_one_through` association requires the user to specify the association upon which it depends as well as the association specified (e.g. the `:family` to which the `:owner` belongs)

## Using Objectify
### Getting Started
1. Download this repo into your project library
2. Model any tables you want to use as Ruby classes (e.g. an :apartments table should be modeled as an "Apartment" class)
3. Require SQLObject at the top of each model file

4. Each object model should inherit from SQLObject (which was included at the top of the file)

```ruby
class House < SQLObject
  belongs_to :owner
  has_one_through :occupying_family, :owner, :family
end
```
N.B. call `::finalize!` on a class after defining it to make use of getter and setter methods.

```ruby
House.finalize! # => makes getters and setters available on column names
```

### Persisting records to the database
Create a new record or update a records attributes
```ruby
house = House.new(address: "5 Elm Street", owner_id=2)
house.save

house.address = "2 Marble Road"
house.save
```

### Querying records
Query the database for records with desired attributes:
```ruby
House.where(address: "1 Main St")
  # => <House:0x007ffe4c8eaaa8 @attributes={:id=>1, :address=>"1 Main St"}>
```

### Using associations
Access associated records directly with association methods:
```ruby
home = House.find(3)
  # => <House:0x007ffe4c8eaaa8 @attributes={:id=>3, :address=>"1 Granite St", :owner_id=>1}>
home.owner
  # =><Owner:0x007err483f32dk @attributes={:id=>1, :name=>"Peter Macdougal", :family_id=>2}>

```

## Technologies
This library was written entirely in Ruby, using ActiveSupport to simplify string manipulation for naming conventions.
