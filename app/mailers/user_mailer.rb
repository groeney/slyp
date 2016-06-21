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
    from = "#{@sender.display_name} <#{@sender.send_reslyp_email_from}>"
    to = @recipient.email
    subject = @reslyp.slyp.display_title
    mail_attributes = { from: from, to: to, subject: subject }
    mail(mail_attributes)
  end

  def reslyp_email_contact(reslyp)
    @reslyp = reslyp
    @slyp = reslyp.slyp
    @recipient = @reslyp.recipient
    @sender = @reslyp.sender
    subject = "#{@sender.display_name} sent you: \"#{@slyp.display_title}\""
    mail_attributes = { to: @recipient.email, subject: subject,
                        from: "#{@sender.display_name} <admin@slyp.io>" }
    cc_attributes = { cc: "#{@sender.display_name} <#{@sender.email}>" }
    mail_attributes.merge!(cc_attributes) if @sender.cc_on_reslyp_email_contact
    mail(mail_attributes)
  end

  def closed_beta_thank_you(user)
    @user = user
    mail(to: @user.email, subject: "Thank you! Back soon :)")
  end

  def new_friend_notification(user, friend)
    @user = user
    @friend = friend
    mail(to: @friend.email.to_s,
         subject: "#{@user.display_name} joined you on Slyp",
         from: "Slyp <admin@slyp.io>")
  end
end
