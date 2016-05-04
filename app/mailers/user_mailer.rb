class UserMailer < ApplicationMailer
  def beta_request(beta_request)
    @beta_request = beta_request
    mail(to: @beta_request.email, subject: "waiting for slyp beta")
  end

  def beta_invitation(beta_request)
    @beta_request = beta_request
    mail(to: @beta_request.email, subject: "your invitation to slyp beta :)")
  end

  def new_user_beta(user)
    @user = user
    mail(to: @user.email, subject: "welcome to slyp beta :)")
  end

  def reslyp_notification(reslyp)
    @reslyp = reslyp
    @comment = @reslyp.comment
    @slyp = @reslyp.slyp
    @recipient = @reslyp.recipient
    @sender = @reslyp.sender
    mail(to: @recipient.email,
      subject: @comment.truncate(50),
      from: "slyp.io <robot@slyp.io>" )
  end
end
