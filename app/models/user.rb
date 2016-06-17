class User < ActiveRecord::Base
  extend ApplicationHelper
  attr_reader :raw_invitation_token
  after_create :send_welcome_email
  after_create :remove_from_waitlist
  after_create :befriend_inviter
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
  scope :all_except, ->(user) { where.not(id: user) }
  enum status: [:active, :invited, :waitlisted]

  before_save :ensure_authentication_token
  before_invitation_created :set_invited_status
  after_invitation_accepted :set_active_status

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
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
    UserMailer.new_user_beta(self).deliver_later unless invited?
  end

  def remove_from_waitlist
    BetaRequest.find_by(email: email).try(:update, signed_up: true)
  end

  def befriend_inviter
    befriend(invited_by_id, false) unless invited_by_id.nil?
  end

  def display_name
    full_name.empty? ? email : full_name
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
    unless friendship = Friendship.find_by(user_id: id, friend_id: friend_id)
      friendship = Friendship.create(user_id: id, friend_id: friend_id)
      self.new_friend(User.find(friend_id)) if notify
    end
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

  def new_friend(friend)
    UserMailer.new_friend(self, friend).deliver_later
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

  def apply_omniauth(auth)
    auth = User.ensure_valid_oauth_params(auth)
    self.provider = auth.provider
    self.uid = auth.uid
    self.image = auth.info.image
    self.first_name = auth.info.first_name
    self.last_name = auth.info.last_name
    self.authentication_token = auth.credentials.token
    self.password = Devise.friendly_token[0, 20] if self.encrypted_password.blank?
    save
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
