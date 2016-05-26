class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: "User"
  validates_uniqueness_of :user_id, scope: :friend_id
  after_create :reciprocate_friendship

  def reciprocate_friendship
    return if Friendship.exists?(user_id: friend_id, friend_id: user_id)
    Friendship.create(user_id: friend_id, friend_id: user_id)
  end

  def self.friends?(user_1, user_2)
    Friendship.exists?(user_id: user_1, friend_id: user_2) &&
      Friendship.exists?(user_id: user_2, friend_id: user_1)
  end
end
