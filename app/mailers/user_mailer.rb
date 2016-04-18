class UserMailer < ApplicationMailer
  def beta_request_email(beta_request)
    @beta_request = beta_request
    mail(to: @beta_request.email, subject: "Waiting for Slyp Beta")
  end

  def beta_invitation_email(beta_request)
    @beta_request = beta_request
    mail(to: @beta_request.email, subject: "Your invitation to Slyp Beta :)")
  def new_user_beta_message(user)
    @user = user
    mail(to: @user.email, subject: "welcome to slyp beta :)")
  end
end
