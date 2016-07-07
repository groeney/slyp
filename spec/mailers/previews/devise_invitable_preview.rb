# Preview all emails at http://localhost:3000/rails/mailers/devise_invitable/mailer
class DeviseInvitable::MailerPreview < ActionMailer::Preview
  def regular_invite
    user = User.create(first_name: "Mary", last_name: "Jones")
    Devise.mailer.invitation_instructions(user, "thisisarandomtoken")
  end
end
