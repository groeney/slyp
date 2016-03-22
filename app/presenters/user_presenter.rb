class UserPresenter < BasePresenter
  attr_accessor :user
  delegate :id, :first_name, :last_name, :email, to: :user

  def initialize(user, is_friend = false)
    @user = user
    @is_friend = is_friend
  end

  def is_friend
    @is_friend == true
  end

  def full_name
    [user.first_name, user.last_name].reject(&:empty?).join(" ")
  end
end