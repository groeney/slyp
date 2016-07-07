class UserMailer < ApplicationMailer
  def joined_waitlist(user)
    @user = user
    mail(to: @user.email, subject: "Joined Slyp waitlist")
  end

  def promoted_from_waitlist(user, raw_token)
    @resource = user
    @token = raw_token
    mail(to: @resource.email, subject: "Join Slyp!")
  end

  def new_user_beta(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Slyp")
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
                        from: "#{@sender.display_name} <support@slyp.io>" }
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
         from: "Slyp Team <support@slyp.io>")
  end

  def activity(user)
    @user = user
    @people = user.activity_people
    @notifications = user.activity_sum
    @slyps = user.user_slyps_with_activity.count
    mail(to: @user.email, subject: "Notifications from #{@people}",
         from: "Slyp Team <support@slyp.io>")
  end
end
