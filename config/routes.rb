Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: "home#index"
  resources :users, only: [:index]
  get "/feed" => "home#feed"
  resources :user_slyps, only: [:create, :index, :show, :destroy, :update]
  resources :reslyps, only: [:create, :index, :destroy]
end
