Rails.application.routes.draw do
  root to: 'pages#home'
  
  resources :users

  namespace :admin do
    resources :products
  end
end
