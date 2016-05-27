class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  serialization_scope :view_context

  before_action :authenticate_user_from_token!
  before_action :set_last_seen_at

  def after_sign_up_path_for(_resource)
    "/feed"
  end

  def after_sign_in_path_for(_resource)
    "/feed"
  end

  private

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      sign_in user
    end
  end

  def set_last_seen_at
    return unless current_user && (session[:last_seen_at].nil? ||
                                   session[:last_seen_at] < 15.minutes.ago)
    current_user.update_attribute(:last_seen_at, Time.now)
    session[:last_seen_at] = Time.now
  end
end
