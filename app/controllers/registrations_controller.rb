class RegistrationsController < Devise::RegistrationsController
  def beta_request
    @beta_request = BetaRequest.create(beta_request_params)
    if @beta_request.valid?
      UserMailer.beta_request_email(@beta_request).deliver_now
      render status: 201, json: { priority: @beta_request.id }
    else
      render status: 422, json: { error: @beta_request.errors.full_messages }
    end
  end
  private
  def beta_request_params
    params.permit(:email)
  end

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end
end