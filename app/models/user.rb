class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  after_create :send_welcome_email
  after_create :remove_from_waitlist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2, :facebook]

  has_many :user_slyps
  has_many :slyps, through: :user_slyps
  has_many :sent_reslyps, through: :user_slyps
  has_many :received_reslyps, through: :user_slyps
  has_many :friendships
  has_many :friends, through: :friendships
  scope :all_except, ->(user) { where.not(id: user) }

  def send_welcome_email
    UserMailer.new_user_beta(self).deliver_later
  end

  def remove_from_waitlist
    BetaRequest.find_by({:email => self.email}).try(:update, {:signed_up => true})
  end

  def display_name
    return self.first_name.empty? ? self.email :
      [self.first_name, self.last_name].reject(&:empty?).join(" ")
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.name   # assuming the user model has a name
    end
  end
end
