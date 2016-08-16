require_relative 'db_connection'
require_relative 'associatable'
require_relative 'searchable'
require 'active_support/inflector'

class SQLObject

  def self.columns
    return @columns if @columns

    query = <<-SQL
      SELECT *
      FROM #{table_name}
    SQL

    @columns = DBConnection.execute2(query).first.map { |el| el.to_sym }
  end

  def self.finalize!
    self.columns.each do |col|

      define_method(col) do
        self.attributes[col]
      end

      define_method("#{col}=") do |el|
          self.attributes[col] = el
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    return @table_name if @table_name
    self.to_s.tableize
  end

  def self.all
    query = <<-SQL
      SELECT *
      FROM #{table_name}
    SQL

    results = DBConnection.execute(query)
    parse_all(results)
  end

  def self.parse_all(results)
    new_instances = results.map do |el|
      new(el)
    end

    new_instances
  end

  def self.find(id)
    query = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE id = ?
      LIMIT 1
    SQL

    result = DBConnection.execute(query, id).first
    new(result) unless result.nil?
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      att = attr_name.to_sym

      unless self.class.columns.include?(att)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{att}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    values = self.class.columns.map do |col|
      send(col)
    end
  end

  def insert
    cols = self.class.columns
    col_names = "(#{cols.drop(1).join(", ")})"
    question_marks = "(#{Array.new(attributes.length,"?").join(",")})"
    table_name = self.class.table_name

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO #{table_name}
        #{col_names}
      VALUES
        #{question_marks}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map { |col| "#{col}=?"}.join(", ")
    table_name = self.class.table_name

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{table_name}
      SET
        #{set_line}
      WHERE
        #{table_name}.id=?
    SQL
  end

  def save
    id.nil? ? insert : update
  end

end
