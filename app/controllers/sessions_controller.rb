class SessionsController < Devise::SessionsController
  def create
    params[:user][:remember_me] = 1
    super
  end
end
