class HomeController < ApplicationController
  helper_method :resource_name, :resource, :devise_mapping

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def index
    if current_user
      redirect_to "/feed"
    end
  end

  def feed
    authenticate_user!
    @user = current_user
  end
end
