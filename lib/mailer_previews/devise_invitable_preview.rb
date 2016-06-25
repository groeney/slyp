# Preview DeviseInvitable emails
class DeviseInvitable::MailerPreview < ActionMailer::Preview
  def regular_invite
    user = User.create(first_name: "Mary", last_name: "Jones")
    Devise.mailer.invitation_instructions(user, "thisisarandomtoken")
  end
end
