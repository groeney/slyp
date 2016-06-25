class InvitationsController < Devise::InvitationsController

  before_action :update_sanitized_params, only: :update
  prepend_before_filter :require_no_authentication, :only => [:edit, :update, :destroy, :waitlist]
  after_action :complete_update, only: :update

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    set_minimum_password_length if respond_to? :set_minimum_password_length
    resource.invitation_token = params[:invitation_token]
    session[:invitation_token] = params[:invitation_token]
    @invitee = resource
    @inviter = User.find_by_id(@invitee.invited_by_id)
    render :edit
  end


  # PUT /users/waitlist
  def waitlist
    raw_invitation_token = update_resource_params[:invitation_token]
    resource = User.find_by_invitation_token(raw_invitation_token, true)
    flash[:notice] = "We added you to the waitlist. Go back to the invitation page and continue with Facebook to sign up." if resource.update(update_waitlist_params)
    resource.add_to_waitlist
    redirect_to root_path
  end

  protected

  def complete_update
    session[:invitation_token] = nil
    resource.send_welcome_email
  end

  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation) do |user|
      user.permit(:first_name, :last_name, :password, :password_confirmation, :invitation_token)
    end
  end

  def update_waitlist_params
    params.require(:user).permit(:invitation_token, :first_name, :last_name)
  end
end