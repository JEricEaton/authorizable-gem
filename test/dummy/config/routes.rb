Rails.application.routes.draw do

  mount Authorizable::Engine => "/authorizable"
end
