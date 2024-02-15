class CurrentPasswordMatchesValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if object.authenticate(value)

    object.errors[attribute] << (options[:message] || 'does not match current password')
  end
end
