# http://edgeguides.rubyonrails.org/routing.html
ProjectZero::Application.routes.draw do

  post '/api/:project_id' => 'api#single_post', :project_id => /\d+/
  get '/api/:project_id' => 'api#single_get', :project_id => /\d+/

  namespace :api do
    scope ':api_key', :api_key => /[a-fA-F\d]{32}/ do
      resources :translations, :only => [ :index, :create ]
    end
  end

  devise_for :users

  # resources :assignments
  resources :documents
  resources :snapshots

  resources :projects do
    resources :locales
    resources :tokens
  end

  resources :translations

  resources :jobs

  root :to => 'projects#index'

  match '/exception_test' => 'exception_test#error'
end
