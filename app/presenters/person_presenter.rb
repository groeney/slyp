class PersonPresenter < BasePresenter
  attr_accessor :user, :friendship
  delegate :id, :first_name, :last_name, :display_name, :image, to: :user

  def initialize(user, friendship)
    @user = user
    @friendship = friendship.try(:active?) ? friendship : nil
  end

  def friendship_id
    friendship.try(:id)
  end

  def email
    friendship ? user.email : nil
  end
end
