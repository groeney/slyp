class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
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
  has_many :friendships
  has_many :friends, through: :friendships
  scope :all_except, ->(user) { where.not(id: user) }

  before_save :ensure_authentication_token

  def thank_you
    UserMailer.closed_beta_thank_you(self).deliver_now
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def reslyps
    query = "sender_id = ? or recipient_id = ?"
    Reslyp.where(query, id, id)
  end

  def friend?(user_id)
    friends.exists?(user_id)
  end

  def slyps_exchanged_with(user_id)
    query = "sender_id = ? and recipient_id = ?"
    results_1 = Reslyp.where(query, user_id, id)
    results_2 = Reslyp.where(query, id, user_id)
    results_1.length + results_2.length
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
    UserMailer.new_user_beta(self).deliver_later
  end

  def remove_from_waitlist
    BetaRequest.find_by(email: email).try(:update, signed_up: true)
  end

  def befriend_inviter
    befriend(invited_by_id)
  end

  def display_name
    full_name.empty? ? email : full_name
  end

  def find_mutual_user_slyps(friend_id)
    return active_user_slyps if friend_id == id
    query = "sender_id = ? and recipient_id = ?"
    user_slyps_received = Reslyp.where(query, friend_id, id).pluck(:recipient_user_slyp_id).uniq
    user_slyps_sent = Reslyp.where(query, id, friend_id).pluck(:sender_user_slyp_id).uniq
    UserSlyp.where(id: user_slyps_received + user_slyps_sent)
  end

  def befriend(friend_id)
    Friendship.find_or_create_by(user_id: id, friend_id: friend_id) unless friend_id.nil?
  end

  def self.from_omniauth(auth)
    self.where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.name # assuming the user model has a name
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
