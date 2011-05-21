ProjectZero::Application.routes.draw do

  devise_for :users

  resources :projects do
    resources :locales
  end

  resources :translations
  # resources :tokens

  
  get '/api/:project_id/:locale_code/:token_raw' => 'api#simple'

  post '/api/:project_id' => 'api#single_post'
  get '/api/:project_id' => 'api#single_get'
  # post '/api/:permalink/:raw_token' => ... & validate
  # get '/api/:permalink/:hashed_token' =>
  # post '/api/:api_key/:raw_token' =>
  # get '/api/:api_key/:hashed_token' =>

  root :to => 'locales#show', :project_id => 1, :id => 1
  #root :to => 'projects#index'

  match '/exception_test' => 'exception_test#error'

end
