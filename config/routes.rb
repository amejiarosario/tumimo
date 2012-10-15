Tumimo::Application.routes.draw do
  match 'sign_in' => "sign_in#index"

  get "analysis/index"
  get 'analysis/facebook'

  resources :users

  get "home/index"
  get "sessions/create"
  get "sessions/destroy"

  resources :authentications
  resources :channels
  
  match '/auth/:provider/callback' => 'sessions#create'
  match 'signout', to: 'sessions#destroy', as: 'signout'

  root :to => 'analysis#index'
end
