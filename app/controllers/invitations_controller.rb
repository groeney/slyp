class InvitationsController < Devise::InvitationsController

  before_filter :update_sanitized_params, only: :update
  after_action :complete_update, only: :update

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    set_minimum_password_length if respond_to? :set_minimum_password_length
    resource.invitation_token = params[:invitation_token]
    session[:invitation_token] = params[:invitation_token]
    render :edit
  end

  protected

  def complete_update
    return if resource.invitation_token
    session[:invitation_token] = nil
    resource.send_welcome_email
  end

  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation) do |user|
      user.permit(:first_name, :last_name, :password, :password_confirmation, :invitation_token)
    end
  end
end