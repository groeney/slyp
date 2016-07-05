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
    return unless current_user && current_user.active?
    redirect_to "/feed"
  end

  def feed
    return redirect_to sign_in_url unless current_user
    return redirect_to accept_invitation_path unless current_user.active?
    @user = current_user
  end

  private

  # Cache/set invited_by_id as invite! method will set it to nil
  def accept_invitation_path
    inviter = User.find_by_id(current_user.invited_by_id)
    invitee = User.invite!({ email: current_user.email }, inviter) do |u|
      u.skip_invitation = true
    end
    attrs = { invitation_token: invitee.raw_invitation_token }
    Rails.application.routes.url_helpers
         .accept_user_invitation_path(invitee, attrs)
  end
end
