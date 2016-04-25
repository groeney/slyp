class Reslyp < ActiveRecord::Base
  belongs_to :recipient, :class_name => "User", :foreign_key => :recipient_id
  belongs_to :sender, :class_name => "User", :foreign_key => :sender_id

  belongs_to :sender_user_slyp, :class_name => "UserSlyp", :foreign_key => :sender_user_slyp_id
  belongs_to :recipient_user_slyp, :class_name => "UserSlyp", :foreign_key => :recipient_user_slyp_id

  alias_attribute :user_slyp, :sender_user_slyp

  validates_uniqueness_of :sender_user_slyp_id, :scope => :recipient_id
  validates_uniqueness_of :recipient_user_slyp_id, :scope => :sender_id
  validates_presence_of :recipient
  validates_presence_of :sender
  validates_presence_of :sender_user_slyp
  validates_presence_of :recipient_user_slyp
  validate :not_self_reslyp
  delegate :slyp, to: :sender_user_slyp

  after_create :notify

  def not_self_reslyp
    if self.sender.id == self.recipient.id
      errors.add(:base, "Cannot reslyp to self.")
    end
  end

  def notify
    UserMailer.reslyp_notification(self).deliver_later
  end
end
