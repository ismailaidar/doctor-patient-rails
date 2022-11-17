Rails.application.routes.draw do
  resources :people
  resources :doctors
  post '/doctor/:id/leove/retire', to: 'doctors#retire_leave', as: :leave_retire
end
