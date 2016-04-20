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
    @slyp = @reslyp.slyp
    @to_user = @reslyp.user_slyp.user
    @from_user = @reslyp.user
    mail(to: @to_user.email,
      subject: "reslyp :)",
      from: "#{@from_user.display_name} <#{@from_user.email}>" )
  end
end
