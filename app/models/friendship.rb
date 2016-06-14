class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: "User"
  validates_uniqueness_of :user_id, scope: :friend_id
  after_create :reciprocate_friendship
  before_destroy :check_friendship

  def reciprocate_friendship
    return if Friendship.exists?(user_id: friend_id, friend_id: user_id)
    Friendship.create(user_id: friend_id, friend_id: user_id)
  end

  def self.friends?(alice_id, bob_id)
    Friendship.exists?(user_id: alice_id, friend_id: bob_id) &&
      Friendship.exists?(user_id: bob_id, friend_id: alice_id)
  end

  def self.total_reslyps(alice, bob)
    query = "recipient_id = :bob_id or sender_id = :bob_id"
    alice.reslyps.where(query, bob_id: bob.id).count
  end

  def check_friendship
    if shared_content?
      errors[:base] << "Cannot delete friendship as you have exchanged slyps"
      return false
    end
  end

  def shared_content?
    user.mutual_user_slyps? friend_id
  end
end
