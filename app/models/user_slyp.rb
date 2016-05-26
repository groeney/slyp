class UserSlyp < ActiveRecord::Base
  belongs_to :slyp
  belongs_to :user
  has_many :sent_reslyps,
           foreign_key: "sender_user_slyp_id", class_name: "Reslyp"
  has_many :received_reslyps,
           foreign_key: "recipient_user_slyp_id", class_name: "Reslyp"
  validates_uniqueness_of :slyp_id, scope: :user_id
  validates_presence_of   :slyp
  validates_presence_of   :user

  def reslyps
    query = "sender_user_slyp_id = ? or recipient_user_slyp_id = ?"
    Reslyp.where(query, id, id)
  end

  def replies
    reslyps.map(replies).flatten
  end

  def add_unseen_activity
    update_attributes(unseen_activity: true, archived: false)
  end

  def friends
    User.where(id: friend_ids)
  end

  def friend_ids
    ids = reslyps.pluck(:sender_id) + reslyps.pluck(:recipient_id)
    ids - [user.id]
  end

  def friends_count
    friend_ids = [reslyps.pluck(:sender_id) + reslyps.pluck(:recipient_id)]
                 .uniq - [user.id]
    friend_ids.length
  end

  def send_slyps(emails, comment = "")
    emails.map { |email| send_slyp(email, comment) }
  end

  def send_slyp(email, comment = "")
    to_user = invite_user_if_necessary(email)
    to_user_slyp = to_user.user_slyps
                          .find_or_create_by(slyp_id: slyp_id) do |user_slyp|
                            user_slyp.update_attribute(:unseen, true)
                          end
    to_user_slyp.add_unseen_activity
    attributes = build_reslyp_attributes(to_user, to_user_slyp, comment)
    return sent_reslyps.create(attributes) unless to_user.invitation_pending?
    Reslyp.without_callback(:create, :after, :notify) do
      return sent_reslyps.create(attributes)
    end
  end

  private

  def invite_user_if_necessary(email)
    to_user = User.find_by(email: email)
    return to_user unless to_user.nil?
    User.without_callback(:create, :after, :send_welcome_email) do
      return User.invite!({ email: email }, user)
    end
  end

  def build_reslyp_attributes(to_user, to_user_slyp, comment)
    {
      recipient_id: to_user.id,
      recipient_user_slyp_id: to_user_slyp.id,
      sender_id: user_id,
      sender_user_slyp_id: id,
      comment: comment,
      slyp_id: slyp_id
    }
  end
end
