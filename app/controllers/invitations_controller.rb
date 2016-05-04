class InvitationsController < Devise::InvitationsController

  before_filter :update_sanitized_params, only: :update

  # PUT /resource/invitation
  def update
    respond_to do |format|
      invitation_token = Devise.token_generator.digest(resource_class, :invitation_token, update_resource_params[:invitation_token])
      format.js do
        self.resource = resource_class.where(invitation_token: invitation_token).first
        resource.send_welcome_email
        resource.skip_password = true
        resource.update_attributes update_resource_params.except(:invitation_token)
      end
      format.html do
        resource_class.where(invitation_token: invitation_token).first.send_welcome_email
        super
      end
    end
  end

  protected

  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation) do |user|
      user.permit(:first_name, :last_name, :password, :password_confirmation, :invitation_token)
    end
  end
end