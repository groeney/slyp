class FriendshipPresenter < BasePresenter
  attr_accessor :friendship
  delegate :id, :friend, to: :friendship
  def initialize(friendship)
    @friendship = friendship
  end
end
