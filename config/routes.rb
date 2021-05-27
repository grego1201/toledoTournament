Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "welcome#index"

  resources :competitions
  resources :fencers
  resources :teams
  resources :poules

  get "welcome/index"
  post '/generate_random_teams', to: 'teams#generate_random_teams'
  post '/export_fencers_text', to: 'fencers#export_text'
  post '/export_fencers_file', to: 'fencers#export_file'
  get '/import_fencers', to: 'fencers#import'
  post '/import_fencers_text', to: 'fencers#import_text'
  post '/import_fencers_file', to: 'fencers#import_file'
  post '/generate_random_poules', to: 'poules#generate_random_poules'
  post '/add_poule_result/:id', to: 'poules#add_poule_result'
  post 'calculate_poule_classification', to: 'poules#calculcate_classification'
end
