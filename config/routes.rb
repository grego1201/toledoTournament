Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'competitions#index'

  resources :competitions
  resources :fencers
  resources :teams

  post '/generate_random_teams', to: 'teams#generate_random_teams'
end
