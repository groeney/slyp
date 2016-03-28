Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: "home#index"
  get "/feed" => "home#feed"
  get "/friends" => "users#friends"
  post "/search/users" => "search#users"
  resources :users, only: [:index]
  resources :user_slyps, only: [:create, :index, :show, :update]
  resources :reslyps, only: [:create, :index, :destroy]
end
