Rails.application.routes.draw do
  resource :sessions, :only => [:new, :create, :destroy]
  resources :password_resets

  # match 'sign_up'  => 'users#new', :as => 'sign_up'
  match 'sign_in'  => 'sessions#new', :as => 'sign_in'
  match 'sign_out' => 'sessions#destroy', :via => :delete, :as => 'sign_out'
end