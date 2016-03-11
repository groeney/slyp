class UserSlyp < ActiveRecord::Base
  belongs_to :slyp
  belongs_to :user
  has_many :reslyps

  def friend_reslyps
    sent = self.reslyps
    received = received_reslyps
    sent + received
  end

  def received_reslyps
    Reslyp.where({
      :receiver_user_slyp_id => self.id,
      :slyp_id => self.slyp_id
      })
  end

  def friend_reslyps_count
    self.friend_reslyps.count
  end
end
