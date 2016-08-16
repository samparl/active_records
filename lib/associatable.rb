require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions

  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions

  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :primary_key => :id,
      :class_name => name.to_s.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions

  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :primary_key => :id,
      :class_name => name.singularize.to_s.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      options.model_class.where(
        options.primary_key => send(options.foreign_key)
      ).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name.to_s, self.to_s, options)
    define_method(name) do
      key_value = send(options.primary_key)
      options.model_class
        .where(options.foreign_key => key_value)
    end
  end


  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]
    define_method(name) do
      through_class = through_options.model_class
      source_options = through_class.assoc_options[source_name]

      key_value = self.send(through_options.primary_key)
      source_key = source_options.primary_key
      source_class = source_options.model_class
      result = source_class.where(source_key => key_value).first

      result
    end
  end
end
