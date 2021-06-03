Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "fencers#index"

  resources :competitions
  resources :fencers
  resources :teams
  resources :poules
  resources :elimination_groups

  get "welcome/index"
  post '/generate_random_teams', to: 'teams#generate_random_teams'
  post '/export_fencers_text', to: 'fencers#export_text'
  post '/export_fencers_file', to: 'fencers#export_file'
  get '/import_fencers', to: 'fencers#import'
  post '/import_fencers_text', to: 'fencers#import_text'
  post '/import_fencers_file', to: 'fencers#import_file'
  post '/generate_random_poules', to: 'poules#generate_random_poules'
  post '/export_classification_file', to: 'poules#export_classification_file'
  post '/add_poule_result/:id', to: 'poules#add_poule_result'
  post '/generate_groups', to: 'elimination_groups#generate'
  post '/add_group_result/:id', to: 'elimination_groups#add_group_result'
  get '/classification', to: 'poules#classification'
  get '/final_classification', to: 'elimination_groups#final_classification'
  post '/final_classification_to_pdf', to: 'elimination_groups#final_classification_to_pdf'
  post '/add_final_classification/:id', to: 'elimination_groups#add_final_classification'
end
