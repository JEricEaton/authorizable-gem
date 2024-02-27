Rails.application.routes.draw do
  resource :sessions, only: %i[new create destroy]
  resources :password_resets
  resources :impersonations, only: %i[create stop] do
    post :stop, on: :collection
  end

  get 'sign_in' => 'sessions#new', :as => 'sign_in'
  delete 'sign_out' => 'sessions#destroy', :as => 'sign_out'

  namespace :admin do
    resources :abuses do
      post :unban, on: :member
    end
  end
end
