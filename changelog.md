## v0.3.5 - 3 Nov 2012

- admin? definition removed from Authorizable::User - it is the apps responsibility.

## v0.3.4 - 31 Oct 2012

- Got rid of attr_accessible in User module to allow strong_parameters from working correctly.
- strong_parameters gem usage is required.

## v0.3.3 - 29 Oct 2012

- Logged in user has access to all resources unless the namespace is protected - then the access has to be explicitly allowed to a role using 'group_access' controller method
- `public_resources` method was replaced by `group_access` which passes in an instance of ResourceAccess which responds to the `allow` method
- User instance from the application needs to define `access_roles` which should return an array of namespaces the user has access to as symbols


## v0.1.9 - 8 Sep 2012

Explicit current password validation. Always use this in your password change controller:

  user.validate_current_password = true
  user.update_attributes user_params
  
In the above example :current_password has to be included in the params and match the actual current password.