class FriendshipPresenter < BasePresenter
  attr_accessor :friendship, :friend
  delegate :id, to: :friendship
  delegate :email, :display_name, to: :friend

  def initialize(friendship)
    @friendship = friendship
    @friend = friendship.friend
  end

  def friend_id
    friend.id
  end
end
