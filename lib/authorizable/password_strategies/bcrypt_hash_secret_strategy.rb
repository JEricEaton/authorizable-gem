class BcryptHashSecretStrategy
  def self.digest(password)
    BCrypt::Engine.hash_secret(password, Authorizable.configuration.password_salt)
  end
end