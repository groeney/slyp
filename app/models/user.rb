class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  after_create :send_welcome_email
  after_create :remove_from_waitlist
  after_create :befriend_inviter

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

  def friend?(user_id)
    friends.exists?(user_id)
  end

  def slyps_exchanged_with(user_id)
    find_mutual_user_slyps(user_id).length
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
    user_slyp_friend_map = Hash[user_slyps.map { |el| [el.id, el.friend_ids] }]
    user_slyp_ids = user_slyp_friend_map
                    .select{ |key, ids| ids.include? friend_id }.keys
    UserSlyp.where(id: user_slyp_ids)
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
end
