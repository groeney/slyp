class UserSearchPresenter < BasePresenter
  attr_accessor :user
  delegate :id, :email, :image, to: :user

  def initialize(user)
    @user = user
  end

  def display_name
    pending = " (pending)"
    user.invitation_pending? ? user.display_name + pending : user.display_name
  end
end
