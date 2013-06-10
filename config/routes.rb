Rails.application.routes.draw do
  resource :sessions, :only => [:new, :create, :destroy]
  resources :password_resets
  resources :impersonations, :only => [:create, :stop] do
    post :stop, on: :collection
  end

  # match 'sign_up'  => 'users#new', :as => 'sign_up'
  match 'sign_in'  => 'sessions#new', :as => 'sign_in'
  match 'sign_out' => 'sessions#destroy', :via => :delete, :as => 'sign_out'
  
  namespace :admin do
    resources :abuses do
      post :unban, on: :member
    end
  end
end