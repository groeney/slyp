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

  def reslyp_friend(reslyp)
    @reslyp = reslyp
    @recipient = @reslyp.recipient
    @sender = @reslyp.sender
    mail_attributes = { to: @recipient.email, subject: @reslyp.slyp.title,
                        from: "#{@sender.display_name} <#{@sender.email}>" }
    mail(mail_attributes)
  end
  end

  def closed_beta_thank_you(user)
    @user = user
    mail(to: @user.email, subject: "Thank you! Back soon :)")
  end

  def new_friend(user, friend)
    @user = user
    @friend = friend
    mail(to: "#{@existing_user.email}",
         subject: "#{@friend.display_name} joined you on Slyp",
         from: "Slyp <robot@slyp.io>")
  end
end
