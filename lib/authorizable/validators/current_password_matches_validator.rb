class CurrentPasswordMatchesValidator < ActiveModel::EachValidator  
  
  def validate_each(object, attribute, value)  
    unless object.digest_password(value) == object.password_digest
      object.errors[attribute] << (options[:message] || "does not match current password")  
    end  
  end  
  
end