class UserSlyp < ActiveRecord::Base
  belongs_to :slyp
  belongs_to :user
  has_many :sent_reslyps, foreign_key: "sender_user_slyp_id",
            class_name: "Reslyp", dependent: :destroy
  has_many :received_reslyps, foreign_key: "recipient_user_slyp_id",
           class_name: "Reslyp", dependent: :destroy
  validates_uniqueness_of :slyp_id, scope: :user_id
  validates_presence_of   :slyp
  validates_presence_of   :user

  def unseen_replies
    reslyps.includes(:replies).map { |el|
      el.replies.where.not(sender_id: user_id).where(seen: false).length
    }.sum
  end

  def reslyps
    query = "sender_user_slyp_id = ? or recipient_user_slyp_id = ?"
    Reslyp.where(query, id, id)
  end

  def new_activity
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
    to_user = find_or_invite_user(email)
    to_user_slyp = to_user.user_slyps
                          .find_or_create_by(slyp_id: slyp_id) do |user_slyp|
                            user_slyp.update_attribute(:unseen, true)
                          end
    to_user_slyp.new_activity
    attributes = build_reslyp_attributes(to_user, to_user_slyp, comment)
    return sent_reslyps.create(attributes) unless to_user.invitation_pending?
    Reslyp.without_callback(:create, :after, :notify) do
      return sent_reslyps.create(attributes)
    end
  end

  def latest_conversation
    conversation = [latest_reslyp, latest_reply].reject(&:nil?)
                                                 .max_by { |el| el.created_at }
    text = conversation.try(:comment) || conversation.try(:text) || ""
    email = conversation.try(:sender).try(:email) || ""
    first_name = conversation.try(:sender).try(:first_name) || ""
    reslyp_id = conversation.try(:reslyp_id) || conversation.try(:id)
    { text: text, email: email, first_name: first_name, reslyp_id: reslyp_id }
  end

  def latest_reslyp
    reslyps.last
  end

  def latest_reply
    replies = reslyps.includes(:replies).map { |el| el.replies }.flatten
    replies.max_by { |el| el.created_at }
  end

  def total_reslyps
    Reslyp.where(slyp_id: slyp_id).length
  end

  def total_favourites
    UserSlyp.where(slyp_id: slyp_id, favourite: true).length
  end

  private

  def find_or_invite_user(email)
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
