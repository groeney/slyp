class Reslyp < ActiveRecord::Base
  belongs_to :recipient, class_name: "User", foreign_key: :recipient_id
  belongs_to :sender, class_name: "User", foreign_key: :sender_id
  belongs_to :sender_user_slyp,
             class_name: "UserSlyp", foreign_key: :sender_user_slyp_id
  belongs_to :recipient_user_slyp,
             class_name: "UserSlyp", foreign_key: :recipient_user_slyp_id
  belongs_to :slyp

  has_many :replies
  alias_attribute :user_slyp, :sender_user_slyp

  validates_uniqueness_of :sender_user_slyp_id, scope: :recipient_id
  validates_uniqueness_of :recipient_user_slyp_id, scope: :sender_id
  validates_presence_of :recipient
  validates_presence_of :sender
  validates_presence_of :sender_user_slyp
  validates_presence_of :recipient_user_slyp
  validates_presence_of :comment
  validate do |reslyp|
    user_slyp_owned_by_user reslyp.sender_user_slyp, reslyp.sender
  end
  validate do |reslyp|
    user_slyp_owned_by_user reslyp.recipient_user_slyp, reslyp.recipient
  end

  delegate :slyp, to: :sender_user_slyp
  after_create :befriend
  after_create :notify

  def self.authorized_find(user, id)
    reslyp = Reslyp.find(id)
    raise ActiveRecord::RecordNotFound unless reslyp.owner(user)
    reslyp
  end

  def owner(user)
    sender == user || recipient == user
  end

  def self_reslyp?
    sender.try(:id) == recipient.try(:id)
  end

  def user_slyp_owned_by_user(user_slyp, user)
    error_msg = "One of the user_slyps is not owned by the corresponding user."
    begin
      id = user_slyp.id
      errors.add(:base, error_msg) if user.user_slyps.find_by_id(id).nil?
    rescue
      errors.add(:base, error_msg)
    end
  end

  def reply_count
    replies.length
  end

  def unseen_replies(user_id)
    replies.where.not(sender_id: user_id).where(seen: false).length
  end

  def notify
    return unless recipient.notify_reslyp && !self_reslyp?
    return UserMailer.reslyp_friend(self).deliver_later if recipient.active?
    UserMailer.reslyp_email_contact(self).deliver_later
  end

  def befriend
    return if Friendship.friends? sender_id, recipient_id
    Friendship.create(user_id: sender_id, friend_id: recipient_id)
  end
end
