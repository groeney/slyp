Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: "home#index"
  resources :user_slyps
  resources :reslyps
  get "/feed" => "home#feed"
end
