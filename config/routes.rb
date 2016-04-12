Rails.application.routes.draw do
  devise_scope :user do
     post "users/beta_request", to: "registrations#beta_request", as: "beta_request"
  end
  post "/beta_request" => "registrations#beta_request"
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks",
    :registrations => "registrations"
  }
  root to: "home#index"
  get "/feed" => "home#feed"
  get "/friends" => "users#friends"
  post "/search/users" => "search#users"
  get "/search/user_slyps" => "search#user_slyps"

  resources :users, only: [:index]
  resources :user_slyps, only: [:create, :index, :show, :update]
  resources :reslyps, only: [:create, :index, :destroy]
  resources :slyps, only: [:create]
end
