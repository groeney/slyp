Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "registrations",
    invitations: "invitations",
    sessions: "sessions"
  }
  devise_scope :user do
    put "/users/waitlist" => "invitations#waitlist"
    get "/sign_in" => "sessions#new"
  end

  root to: "home#index"
  get "/feed" => "home#feed"
  get "/search/users" => "search#users"
  get "/search/user_slyps" => "search#user_slyps"
  get "/search/friends" => "search#friends"
  get "/search/mutual_user_slyps" => "search#mutual_user_slyps"
  post "/persons/invite" => "persons#invite"
  get "/r/:referral_token" => "referrals#new"
  post "/r/capture" => "referrals#capture"
  get "/user_slyp/:id" => "user_slyps#show"
  put "/user_slyp/:id" => "user_slyps#update"
  post "/users/beta_request" => "users#beta_request"

  resources :persons, only: [:index, :show]
  resources :users, only: [:index]
  resources :friendships, only: [:create, :destroy]
  resources :user_slyps, only: [:create, :index]
  get "/reslyps/:id" => "reslyps#index"
  get "/reslyp/:id" => "reslyps#show"
  resources :reslyps, only: [:create, :destroy]
  resources :slyps, only: [:create]
  resources :replies, only: [:create, :update, :destroy, :show]
  get "/reslyp/replies/:id" => "replies#index"
  put "/user/:id" => "users#update"
  get "/user" => "users#index"
  resource :user

  if Rails.env.development?
    get "/rails/mailers" => "rails/mailers#index"
    get "/rails/mailers/*path" => "rails/mailers#preview"
  end
  # Make sure this is last
  get "*unmatched_route", to: redirect("/")
end
