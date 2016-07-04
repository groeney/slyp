class PersonPresenter < BasePresenter
  attr_accessor :user, :friendship

  delegate :id, :first_name, :last_name, :display_name, :image, :status,
           :email, to: :user

  def initialize(user, friendship)
    @user = user
    @friendship = friendship.try(:active?) ? friendship : nil
  end

  def friendship_id
    friendship.try(:id)
  end
end
