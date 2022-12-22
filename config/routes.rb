Rails.application.routes.draw do
  get 'csv_import/index'
  post 'csv_import/upload'
  resources :patients
  root to: 'pages#index'

  resources :people
  resources :doctors
  resources :appointments
end
