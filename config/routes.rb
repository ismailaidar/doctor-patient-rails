Rails.application.routes.draw do
  resources :patients
  root to: 'pages#index'

  resources :people
  resources :doctors
  resources :appointments
end
