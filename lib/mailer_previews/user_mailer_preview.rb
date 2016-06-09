# Preview UserMailer emails
class UserMailerPreview < ActionMailer::Preview
  def beta_request
    UserMailer.beta_request(BetaRequest.first)
  end

  def beta_invitation
    UserMailer.beta_invitation(BetaRequest.first)
  end

  def new_user_beta
    UserMailer.new_user_beta(User.first)
  end

  def reslyp_friend
    UserMailer.reslyp_friend(Reslyp.first)
  end

  def closed_beta_thank_you
    UserMailer.closed_beta_thank_you(User.first)
  end
end
