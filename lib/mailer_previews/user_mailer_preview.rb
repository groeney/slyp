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

  def reslyp_notification
    UserMailer.reslyp_notification(Reslyp.first)
  end

  def reslyp_notification
    UserMailer.reslyp_notification(Reslyp.first)
  end
end