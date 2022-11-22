Rails.application.routes.draw do
  resources :patients
  resources :people
  resources :doctors
end
