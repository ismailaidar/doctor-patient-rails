Rails.application.routes.draw do
  root to: 'pages#index'

  resources :people
  resources :doctors
end
