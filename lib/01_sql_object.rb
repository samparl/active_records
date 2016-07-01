require_relative 'db_connection'
require 'byebug'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    query = <<-SQL
      SELECT
        *
      FROM
        #{table_name}
    SQL
    @columns = DBConnection.execute2(query).first.map { |el| el.to_sym }
  end

  def self.finalize!
    columns.each do |col|

      var_col = "@#{col}"
      define_method(col) do
        attributes[col]
      end
      # debugger

      define_method("#{col}=") do |el|
          attributes[col] = el
      end

    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    return @table_name if @table_name
    self.to_s.tableize
  end

  def self.all
    # ...
    query = <<-SQL
      SELECT
        *
      FROM
        #{table_name}
    SQL
    results = DBConnection.execute(query)
    parse_all(results)
  end

  def self.parse_all(results)
    # ...
    # debugger
    new_instances = results.map do |el|
      new(el)
    end
    new_instances
  end

  def self.find(id)
    # ...
    query = <<-SQL
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
      LIMIT
        1
    SQL
    result = DBConnection.execute(query, id).first
    new(result) unless result.nil?
  end

  def initialize(params = {})
    # ...
    # debugger
    params.each do |attr_name, value|
      # debugger
      att = attr_name.to_sym
      # debugger
      unless self.class.columns.include?(att)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{att}=", value)
    end
  end

  def attributes
    # ...
    @attributes = {} unless @attributes
    @attributes
  end

  def attribute_values
    # ...
    values = self.class.columns.map do |col|
      send(col)
    end
  end

  def insert
    # ...
    cols = self.class.columns
    question_marks = "(#{Array.new(attributes.length,"?").join(",")})"
    values = attribute_values.join(",")
    debugger
    table_name = self.class.table_name
    DBConnection.execute(<<-SQL, *cols)
      INSERT INTO
        #{table_name}
      VALUES
        #{values}
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
