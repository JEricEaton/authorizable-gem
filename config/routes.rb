Authorizable::Engine.routes.draw do
  resource :session,
    :controller => 'authorizable/sessions',
    :only       => [:new, :create, :destroy]

  # match 'sign_up'  => 'authorizable/users#new', :as => 'sign_up'
  match 'sign_in'  => 'authorizable/sessions#new', :as => 'sign_in'
  match 'sign_out' => 'authorizable/sessions#destroy', :via => :delete, :as => 'sign_out'
end
