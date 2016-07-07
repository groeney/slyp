# Preview all emails at http://localhost:3000/rails/mailers/devise/mailer
class Devise::MailerPreview < ActionMailer::Preview
  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(User.first, "faketoken")
  end

  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.first, "faketoken")
  end
end