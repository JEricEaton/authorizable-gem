class CurrentPasswordMatchesValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if object.authenticate(value)

    object.errors.add(attribute.to_sym, options: { message: options[:message] || 'does not match current password' })
  end
end
