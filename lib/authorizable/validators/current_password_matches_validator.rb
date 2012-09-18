class CurrentPasswordMatchesValidator < ActiveModel::EachValidator  
  
  def validate_each(object, attribute, value)  
    unless object.authenticate(value)
      object.errors[attribute] << (options[:message] || "does not match current password")  
    end  
  end  
  
end