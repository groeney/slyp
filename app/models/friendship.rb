class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: "User"
  validates_uniqueness_of :user_id, scope: :friend_id
  after_create :reciprocate_the_love
  after_destroy :reciprocate_the_hate

  def reciprocate_the_love
    Friendship.where(user_id: friend_id, friend_id: user_id)
              .first_or_create
  end

  def reciprocate_the_hate
    return unless friendship = reciprocal
    friendship.destroy
  end

  def reciprocal
    Friendship.find_by(user_id: friend_id, friend_id: user_id)
  end

  def self.friends?(alice_id, bob_id)
    Friendship.exists?(user_id: alice_id, friend_id: bob_id) &&
      Friendship.exists?(user_id: bob_id, friend_id: alice_id)
  end

  def self.total_reslyps(alice, bob)
    query = "recipient_id = :bob_id or sender_id = :bob_id"
    alice.reslyps.where(query, bob_id: bob.id).count
  end

  def active?
    active && reciprocal.active
  end

  def pending?
    !(active?)
  end

  def active!
    update(active: true) && reciprocal.update(active: true)
  end

  def pending!
    update(active: false) && reciprocal.update(active: false)
  end

  def self_friendship?
    user_id == friend_id
  end
end
