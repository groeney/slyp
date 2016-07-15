class User < ActiveRecord::Base
  extend ApplicationHelper
  attr_reader :raw_invitation_token
  after_create :send_welcome_email
  after_create :befriend_inviter
  after_create :befriend_support
  after_create :set_send_reslyp_email_from

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

  has_many :user_slyps, dependent: :destroy
  has_many :slyps, through: :user_slyps
  has_many :sent_reslyps, through: :user_slyps
  has_many :received_reslyps, through: :user_slyps
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_secure_token :referral_token
  scope :all_except, ->(user) { where.not(id: user) }
  enum status: [:active, :invited, :waitlisted]

  before_save :ensure_authentication_token
  before_save :ensure_referral_token
  before_save :ensure_friends_with_self
  before_invitation_created :set_invited_status
  after_invitation_accepted :set_active_status

  def ensure_authentication_token
    return unless authentication_token.blank?
    self.authentication_token = generate_authentication_token
  end

  def ensure_referral_token
    return if referral_token?
    regenerate_referral_token
  end

  def ensure_friends_with_self
    befriend(id, false)
  end

  def promote_from_waitlist
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.invitation_token = nil
    self.reset_password_token = enc
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)
    set_active_status
    UserMailer.promoted_from_waitlist(self, raw).deliver_later
  end

  def self.promote_all_from_waitlist(email_begins_with = "")
    matcher = "#{email_begins_with}%"
    User.where("email ilike ?", matcher).each do |u|
      u.promote_from_waitlist if u.waitlisted?
    end
  end

  def add_to_waitlist
    UserMailer.joined_waitlist(self).deliver_later
    waitlisted!
  end

  def reslyps
    query = "sender_id = :user_id or recipient_id = :user_id"
    Reslyp.where(query, user_id: id)
  end

  def replies
    Reply.where(sender_id: id)
  end

  def friends?(user_id)
    friends.exists?(user_id)
  end

  def active_user_slyps
    user_slyps.where(archived: false, deleted: false)
  end

  def invitation_pending?
    !invitation_token.nil? && invitation_accepted_at.nil?
  end

  def full_name
    [first_name, last_name].reject(&:empty?).join(" ")
  end

  def send_welcome_email
    UserMailer.new_user_beta(self).deliver_later if active?
  end

  def befriend_inviter
    befriend(invited_by_id, false) unless invited_by_id.nil?
  end

  def befriend_support
    support = User.support_user
    befriend(support.id, true) unless support.nil?
  end

  def display_name
    full_name.empty? ? email : full_name
  end

  def display_name_short
    first_name.empty? ? email : first_name
  end

  # TODO couldn't figure out how to return valid AR object, so went with ids
  def private_user_slyp_ids
    user_slyps.select { |user_slyp| user_slyp.reslyps.count == 0 }
              .map { |user_slyp| user_slyp.id }
  end

  # This is an expensive operation, use with care.
  def mutual_user_slyps(friend_id)
    return active_user_slyps if friend_id.eql? id
    query = "(sender_id = :user_id and recipient_id = :friend_id) OR "\
            "(sender_id = :friend_id and recipient_id = :user_id)"
    user_slyp_ids = Reslyp.where(query, user_id: id, friend_id: friend_id)
                          .pluck(:recipient_user_slyp_id, :sender_user_slyp_id)
                          .flatten.uniq
    user_slyps.where(id: user_slyp_ids)
  end

  def mutual_user_slyps?(friend_id)
    return false unless friends? friend_id
    mutual_user_slyps(friend_id).exists?
  end

  def befriend(friend_id, notify = true)
    return nil if friend_id.nil?
    friendship = Friendship.find_or_create_by(user_id: id, friend_id: friend_id)
    notify = notify && friendship.active? && !friendship.self_friendship?
    new_friend_notification(User.find(friend_id)) if notify
    friendship.active! if friendship.pending?
    friendship
  end

  def friendship(friend_id)
    Friendship.find_by(user_id: id, friend_id: friend_id)
  end

  def social_signup
    return unless provider.eql? "facebook"
    discover_facebook_friends
  end

  def discover_facebook_friends
    graph = Koala::Facebook::API.new(authentication_token)
    graph.get_connections("me", "friends").each do |fb_friend|
      user = User.where(provider: "facebook", uid: fb_friend["id"]).first
      next if user.nil?
      befriend(user.id)
    end
  end

  def new_friend_notification(friend)
    return unless friend.active?
    UserMailer.new_friend_notification(self, friend).deliver_later
  end

  def self.from_omniauth(auth)
    provider, uid, email = parse_oauth_params(auth)
    user = User.find_by(provider: provider, uid: uid)
    if user || (user = User.find_by(email: email))
      user.update(provider: provider, uid: uid)
    else # Completely new user
      user = User.create(provider: provider, uid: uid, email: email)
    end
    user.apply_omniauth(auth)
    user
  end

  def self.support_user
    user = User.find_by(email: "support@slyp.io")
    user = User.create_support_user if user.nil?
    user
  end

  def self.create_support_user
    support_user_attrs = {
      email: "support@slyp.io", first_name: "Slyp", last_name: "Bot"
    }
    User.skip_callback(:save, :before, :ensure_friends_with_support)
    User.without_callback(:create, :after, :send_welcome_email) do
      support = User.find_or_create_by(support_user_attrs)
      support.password = ENV.fetch("SUPPORT_USER_PASSWORD")
      support.save
      return support
    end
    User.set_callback(:save, :before, :ensure_friends_with_support)
  end

  def self.with_activity
    query = "user_slyps.unseen_activity = true and user_slyps.archived = false"
    User.includes(:user_slyps).references(:user_slyps).where(query)
  end

  def activity_sum
    user_slyps_with_activity.map do |user_slyp|
      user_slyp.unseen_replies > 0 ? user_slyp.unseen_replies : 1
    end.sum
  end

  def activity_people
    names_arr = user_slyps_with_activity.map(&:activity_people).flatten.uniq
    l = names_arr.length
    people = names_arr[0..l - 2].join(", ")
    people += " and #{names_arr[l - 1]}" if l > 1
    people
  end

  def user_slyps_with_activity
    query = "user_slyps.unseen_activity = true and user_slyps.archived = false"
    user_slyps.references(:user_slyps).where(query)
  end

  def apply_omniauth(auth)
    auth = User.ensure_valid_oauth_params(auth)
    self.provider = auth.provider
    self.uid = auth.uid
    self.image = (auth.info.image || "").gsub("http://", "https://")
    self.first_name = auth.info.first_name
    self.last_name = auth.info.last_name
    self.authentication_token = auth.credentials.token
    self.password = Devise.friendly_token[0, 20] if encrypted_password.blank?
    if invited?
      self.invitation_token = nil
      self.invitation_accepted_at = Time.now
    end
    save && set_active_status
  end

  def send_activated_outreach_one
    support = User.support_user
    url = "https://medium.com/@jamesgroeneveld/meet-slyp-beta-51ce3bfc90a8"
    slyp = Slyp.fetch(url)
    user_slyp = support.user_slyps.find_or_create_by(slyp_id: slyp.id)
    user_slyp.send_slyp(email, activated_outreach_one_comment) if active?
  end

  def activated_outreach_one_comment
    "Hi #{display_name_short}! I'm slypbot, good to meet you :-) I'm here to"\
    " help out whenever I can. First I want to show you our launch day"\
    " blog post. It will give you a little bit more context around what"\
    " we're all about. Oh and this is what it will look like to a friend"\
    " when you slyp them! One last thing... I can talk, so reply me with"\
    " any or all of your thoughts!"
  end

  def set_send_reslyp_email_from
    update(send_reslyp_email_from: email)
  end

  def referral_link
    Rails.application.routes.url_helpers.root_url + "r/#{referral_token}"
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def set_invited_status
    invited!
  end

  def set_active_status
    active! && self.update(activated_at: Time.now)
    send_activated_outreach_one
  end
end
