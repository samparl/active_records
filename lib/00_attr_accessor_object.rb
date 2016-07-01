require 'byebug'

class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # debugger
    names.each do |name|
      var_name = "@#{name}"
      define_method(name) { instance_variable_get(var_name) }
      define_method("#{name}=") do |el|
        instance_variable_set(var_name, el)
      end
    end

  end
end
