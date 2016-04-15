class UserMailer < ApplicationMailer
  def beta_request_email(beta_request)
    @beta_request = beta_request
    mail(to: @beta_request.email, subject: "Waiting for Slyp Beta")
  end

  def beta_invitation_email(beta_request)
    @beta_request = beta_request
    mail(to: @beta_request.email, subject: "Invitation to Slyp Beta")
  end
end
