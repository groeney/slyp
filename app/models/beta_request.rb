class BetaRequest < ActiveRecord::Base
  validates_uniqueness_of :email, message: "has already been submitted."
  after_create :send_beta_request_email

  def send_beta_request_email
    UserMailer.beta_request(self).deliver_later
  end
end
