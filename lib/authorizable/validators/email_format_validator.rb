class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

    object.errors.add(attribute.to_sym, options: { message: options[:message] || 'is not formatted properly' })
  end
end
