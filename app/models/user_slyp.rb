class UserSlyp < ActiveRecord::Base
  belongs_to :slyp
  belongs_to :user
  has_many :sent_reslyps, foreign_key: "sender_user_slyp_id", class_name: "Reslyp"
  has_many :received_reslyps, foreign_key: "recipient_user_slyp_id", class_name: "Reslyp"
  validates_uniqueness_of :slyp_id, :scope => :user_id
  validates_presence_of   :slyp
  validates_presence_of   :user

  def reslyps
    Reslyp.where("sender_user_slyp_id = ? or recipient_user_slyp_id = ?", self.id, self.id)
  end

  def friends
    reslyps = self.reslyps
    friend_ids = reslyps.pluck(:sender_id) + reslyps.pluck(:recipient_id)
    friend_ids = friend_ids.uniq - [self.user.id]
    User.where(:id => friend_ids)
  end

  def send_slyps(emails, comment="")
    emails.map { |email| self.send_slyp(email, comment) }
  end

  def send_slyp(email, comment="")
    to_user = User.find_or_create_by({:email => email})

    User.without_callback(:create, :after, :send_welcome_email) do
      if to_user.encrypted_password.blank?
        to_user.password = "password"   # TODO send invite email
        to_user.save!
      end
    end

    to_user_slyp = to_user.user_slyps.find_or_create_by({:slyp_id => self.slyp_id})
    to_user_slyp.update_attribute(:archived, false)

    self.sent_reslyps.create({
      :recipient_id            => to_user.id,
      :recipient_user_slyp_id  => to_user_slyp.id,
      :sender_id               => self.user.id,
      :sender_user_slyp_id     => self.id,
      :comment                 => comment,
      :slyp_id                 => self.slyp_id
      })
  end
end
