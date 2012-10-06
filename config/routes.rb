Tumimo::Application.routes.draw do
  resources :users

  get "home/index"
  get "sessions/create"
  get "sessions/destroy"

  resources :authentications
  resources :channels
  
  match '/auth/:provider/callback' => 'sessions#create'
  match 'signout', to: 'sessions#destroy', as: 'signout'

  root :to => 'home#index'
end
