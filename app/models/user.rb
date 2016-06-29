class User < ActiveRecord::Base
  extend ApplicationHelper
  attr_reader :raw_invitation_token
  after_create :send_welcome_email
  after_create :befriend_inviter
  after_create :befriend_support
  before_destroy :thank_you

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
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def ensure_referral_token
    unless referral_token?
      regenerate_referral_token
    end
  end

  def ensure_friends_with_self
    befriend(id, false)
  end

  def promote_from_waitlist
    update(invitation_token: nil)
    active!
  end

  def add_to_waitlist
    UserMailer.joined_waitlist(self).deliver_later
    waitlisted!
  end

  def thank_you
    UserMailer.closed_beta_thank_you(self).deliver_now
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
    self.new_friend_notification(User.find(friend_id)) if notify
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
    UserMailer.new_friend_notification(self, friend).deliver_later if friend.active?
  end

  def self.from_omniauth(auth)
    provider, uid, email = parse_oauth_params(auth)
    user = User.find_by(provider: provider, uid: uid)
    if user || user = User.find_by(email: email)
      user.update(provider: provider, uid: uid)
    else # Completely new user
      user = User.create(provider: provider, uid: uid, email: email)
    end
    user.apply_omniauth(auth)
    user
  end

  def self.support_user
    user = User.find_by(email: "support@slyp.io")
    if user.nil?
      user = User.create_support_user
    end
    user
  end

  def self.create_support_user
    support_user_attrs = {
      email: "support@slyp.io", first_name: "Slyp", last_name: "Team"
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
    names_arr = user_slyps_with_activity.map do |user_slyp|
      user_slyp.activity_people
    end.flatten.uniq
    l = names_arr.length
    people = names_arr[0..l-2].join(", ")
    people += " and #{names_arr[l-1]}" if l > 1
    return people
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
    self.password = Devise.friendly_token[0, 20] if self.encrypted_password.blank?
    save
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
    active!
  end
end
