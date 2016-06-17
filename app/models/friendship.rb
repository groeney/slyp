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
    return unless friendship = Friendship.find_by(user_id: friend_id, friend_id: user_id)
    friendship.destroy
  end

  def self.friends?(alice_id, bob_id)
    Friendship.exists?(user_id: alice_id, friend_id: bob_id) &&
      Friendship.exists?(user_id: bob_id, friend_id: alice_id)
  end

  def self.total_reslyps(alice, bob)
    query = "recipient_id = :bob_id or sender_id = :bob_id"
    alice.reslyps.where(query, bob_id: bob.id).count
  end
end
