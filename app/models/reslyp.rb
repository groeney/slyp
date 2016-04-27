class Reslyp < ActiveRecord::Base
  belongs_to :recipient, :class_name => "User", :foreign_key => :recipient_id
  belongs_to :sender, :class_name => "User", :foreign_key => :sender_id

  belongs_to :sender_user_slyp, :class_name => "UserSlyp", :foreign_key => :sender_user_slyp_id
  belongs_to :recipient_user_slyp, :class_name => "UserSlyp", :foreign_key => :recipient_user_slyp_id

  belongs_to :slyp

  has_many :replies
  alias_attribute :user_slyp, :sender_user_slyp

  validates_uniqueness_of :sender_user_slyp_id, :scope => :recipient_id
  validates_uniqueness_of :recipient_user_slyp_id, :scope => :sender_id
  validates_presence_of :recipient
  validates_presence_of :sender
  validates_presence_of :sender_user_slyp
  validates_presence_of :recipient_user_slyp
  validates_presence_of :comment
  validate :not_self_reslyp

  validate do |reslyp|
    user_slyp_owned_by_user reslyp.sender_user_slyp, reslyp.sender
  end

  validate do |reslyp|
    user_slyp_owned_by_user reslyp.recipient_user_slyp, reslyp.recipient
  end

  delegate :slyp, to: :sender_user_slyp

  after_create :notify

  def self.authorized_find(user, id)
    reslyp = Reslyp.find(id)
    if reslyp.owner(user)
      reslyp
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def owner(user)
    self.sender == user or self.recipient == user
  end

  def not_self_reslyp
    if self.sender.try(:id) == self.recipient.try(:id)
      errors.add(:base, "Cannot reslyp to self.")
    end
  end

  def user_slyp_owned_by_user(user_slyp, user)
    begin
      if user.user_slyps.find_by_id(user_slyp.id).nil?
        errors.add(:base, "One of the user_slyps is not owned by the corresponding user")
      end
    rescue
      errors.add(:base, "One of the user_slyps is not owned by the corresponding user")
    end
  end

  def notify
    UserMailer.reslyp_notification(self).deliver_later
  end
end
