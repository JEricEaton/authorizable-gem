Rails.application.routes.draw do

  resources :users

  mount Authorizable::Engine => "/authorizable"
end
