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
    reslyps.includes(:replies).map do |reslyp|
      reslyp.replies.where.not(sender_id: user_id).where(seen: false).length
    end.sum
  end

  def activity_people
    if unseen_activity
      reslyps.includes(:replies).map do |reslyp|
        if unseen_replies > 0
          replies = reslyp.replies.where.not(sender_id: user_id).where(seen: false)
          replies.map { |reply| reply.sender.display_name_short }.uniq
        else
          [latest_reslyp.other(user_id).display_name_short]
        end
      end.flatten.uniq
    end
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
    return ids - [user.id] unless self_reslyp?
    ids
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
    return self_reslyp(comment) if to_user.id == user_id
    to_user_slyp = to_user.user_slyps
                          .find_or_create_by(slyp_id: slyp_id) do |user_slyp|
                            user_slyp.update_attribute(:unseen, true)
                          end
    to_user_slyp.new_activity unless to_user_slyp.id == id
    attributes = build_reslyp_attributes(to_user, to_user_slyp, comment)
    sent_reslyps.create(attributes)
  end

  def self_reslyp(comment)
    sent_reslyps.create(self_reslyp_attributes(comment))
  end

  def self_reslyp?
    reslyps.where(sender_id: user_id, recipient_id: user_id).exists?
  end

  def self_reslyp_attributes(comment)
    {
      recipient_id: user_id,
      recipient_user_slyp_id: id,
      sender_id: user_id,
      sender_user_slyp_id: id,
      comment: comment,
      slyp_id: slyp_id
    }
  end

  def latest_conversation
    conversation = [latest_reslyp, latest_reply].reject(&:nil?)
                                                .max_by(&:created_at)
    parse_params_from_conversation(conversation)
  end

  def parse_params_from_conversation(conversation)
    text = conversation.try(:comment) || conversation.try(:text) || ""
    email = conversation.try(:sender).try(:email) || ""
    first_name = conversation.try(:sender).try(:first_name) || ""
    image = conversation.try(:sender).try(:image) || ""
    reslyp_id = conversation.try(:reslyp_id) || conversation.try(:id)
    { text: text, email: email, first_name: first_name,
      reslyp_id: reslyp_id, image: image }
  end

  def latest_reslyp
    reslyps.last
  end

  def latest_reply
    replies = reslyps.includes(:replies).map(&:replies).flatten
    replies.max_by(&:created_at)
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
      invitee = User.invite!({ email: email }, user) do |u|
        u.skip_invitation = true
      end
      return invitee
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
