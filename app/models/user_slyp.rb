class UserSlyp < ActiveRecord::Base
  belongs_to :slyp
  belongs_to :user
  has_many :reslyps

  validates_uniqueness_of :slyp_id, :scope => :user_id
  validates_presence_of :slyp
  validates_presence_of :user

  def send_slyps(params)
    emails = params[:emails] || []
    comment = params[:comment] || ""
    emails.map { |email| self.send_slyp(email, comment) }
  end

  def send_slyp(email, comment)
    to_user = User.find_or_create_by({:email => email})
    if to_user.encrypted_password.blank?
      to_user.password = "password"   # TODO send registration email
      to_user.save!
    end
    to_user_slyp = to_user.user_slyps.find_or_create_by({:slyp_id => self.slyp_id})

    sent_reslyp = self.reslyps.create({
      :user_id => to_user.id,
      :sender => true,
      :slyp_id => self.slyp_id
      })

    received_reslyp = to_user_slyp.reslyps.create({
      :user_id => self.user.id,
      :sender => false,
      :comment => comment,
      :slyp_id => self.slyp_id
      })

    return {
      :sent_reslyp => sent_reslyp,
      :received_reslyp => received_reslyp
    }
  end
end
